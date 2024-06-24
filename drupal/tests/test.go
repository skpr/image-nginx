package main

import (
	"fmt"
	"net/http"
	"os"
)

// Test which will be executed by this script.
type Test func() error

func main() {
	var errs []error

	tests := []Test{
		// Blocking rules.
		hasStatusCode("http://127.0.0.1:8080/index.PHP", 403),
		hasStatusCode("http://127.0.0.1:8080/tag", 200),
		hasStatusCode("http://127.0.0.1:8080/Tag", 404),
		hasStatusCode("http://127.0.0.1:8080/data.log", 404),
	}

	for _, test := range tests {
		err := test()
		if err != nil {
			errs = append(errs, err)
		}
	}

	if len(errs) > 0 {
		for _, err := range errs {
			fmt.Println("FAILED:", err)
		}

		os.Exit(1)
	}
}

// Check if a url has a specified status code.
func hasStatusCode(url string, code int) Test {
	return func() error {
		resp, err := http.Get(url)
		if err != nil {
			return fmt.Errorf("failed to get host: %w", err)
		}

		if resp.StatusCode != code {
			return fmt.Errorf("url %s does not have corrent status code: have=%d want=%d", url, resp.StatusCode, code)
		}

		return nil
	}
}
