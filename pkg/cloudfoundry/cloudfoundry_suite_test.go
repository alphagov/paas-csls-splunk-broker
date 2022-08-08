package cloudfoundry_test

import (
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

func TestCloudfoundry(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Cloudfoundry Suite")
}
