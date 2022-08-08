package cslsfakes_test

import (
	"testing"

	"github.com/alphagov/paas-csls-splunk-broker/pkg/csls"
	"github.com/alphagov/paas-csls-splunk-broker/pkg/csls/cslsfakes"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("FakeCloudfoundryLogPutter", func() {
	It("Satisfies the interface", func() {
		var _ csls.CloudfoundryLogPutter = &cslsfakes.FakeCloudfoundryLogPutter{}
	})

})

func TestSyslogHttpAdapter(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "SyslogHttpAdapter Suite")
}
