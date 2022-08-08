package main_test

import (
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("stub", func() {

})

func TestSyslogHttpBroker(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "SyslogHttpBroker Suite")
}
