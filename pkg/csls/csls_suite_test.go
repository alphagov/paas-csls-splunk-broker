package csls_test

import (
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

func TestCsls(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Csls Suite")
}
