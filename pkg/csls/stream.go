package csls

import (
	"bytes"
	"compress/gzip"
	"encoding/json"
	"fmt"

	sdk "github.com/alphagov/paas-csls-splunk-broker/pkg/aws"
	"github.com/alphagov/paas-csls-splunk-broker/pkg/cloudfoundry"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/kinesis"
)

const (
	SyslogLogGroup = "rfc5424_syslog"
	SyslogOwner    = "GOV.UK_PaaS"
	SyslogDataType = "DATA_MESSAGE"
)

// LogEvent represents a log message. It mirrors the format of the AWS
// Cloudwatch log event envelope
type LogEvent struct {
	ID        string `json:"id"`
	Timestamp int64  `json:"timestamp"`
	Message   string `json:"message"`
}

// Log represents a collection of Log messages from the same source. It is a
// duplicate of the AWS Cloudwatch Log envelope.
type Log struct {
	Owner               string     `json:"owner"`
	LogGroup            string     `json:"logGroup"`
	LogStream           string     `json:"logStream"`
	SubscriptionFilters []string   `json:"subscriptionFilters"`
	MessageType         string     `json:"messageType"`
	LogEvents           []LogEvent `json:"logEvents"`
}

//go:generate go run github.com/maxbrunsfeld/counterfeiter/v6 . CloudfoundryLogPutter

// CloudfoundryLogPutter forwards cloudfoundry format Logs to stream
type CloudfoundryLogPutter interface {
	PutCloudfoundryLog(log cloudfoundry.Log, logGroupName string) error
}

// Stream represents the input to the csls logging pipeline
type Stream struct {
	// Name is the name of the kinesis stream to write to
	Name string
	// Client is the AWS SDK capable of PutRecord
	AWS sdk.Client
}

// PutCloudfoundryLog transforms cloudfoundry format logs into csls format
// (cloudwatch format) logs and writes them to the csls kinesis stream with a
// given log group name
func (w *Stream) PutCloudfoundryLog(log cloudfoundry.Log, groupName string) error {
	data := Log{
		Owner:       SyslogOwner,
		LogGroup:    groupName,
		LogStream:   log.Hostname,
		MessageType: SyslogDataType,
		LogEvents: []LogEvent{
			{
				ID:        "0",
				Timestamp: log.Timestamp.Unix(), // TODO: should this be UnixNano?
				Message:   log.Message,
			},
		},
	}

	var json bytes.Buffer
	if err := serialzieForKinesis(&data, &json); err != nil {
		return fmt.Errorf("failed-to-serialize-for-kinesis: %s", err)
	}

	// Kinesis client transparently base64 encodes `Data`
	_, err := w.AWS.PutRecord(&kinesis.PutRecordInput{
		StreamName:   aws.String(w.Name),
		Data:         json.Bytes(),
		PartitionKey: aws.String(log.Hostname),
	})
	if err != nil {
		return err
	}
	return nil
}

// Serialize to JSON and GZ compress a Log struct. This is the format
// Cloudwatch uses when subscribing a log group to a Kinesis data
// stream destination.
// https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html
func serialzieForKinesis(log *Log, buffer *bytes.Buffer) error {
	gz := gzip.NewWriter(buffer)

	enc := json.NewEncoder(gz)

	if err := enc.Encode(*log); err != nil {
		return fmt.Errorf("failed-to-json-encode `Log`: %s", err)
	}

	if err := gz.Close(); err != nil {
		return fmt.Errorf("failed-to-close-gz-writer: %s", err)
	}

	return nil
}
