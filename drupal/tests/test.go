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
		// Tests for header: X-Robots-Tag.
		noResponseHeader("http://127.0.0.1:8080", "X-Robots-Tag"),
		noResponseHeader("http://127.0.0.1:8080/core/themes/stable9/css/system/components/ajax-progress.module.css?sfnmnn", "X-Robots-Tag"),
		noResponseHeader("http://127.0.0.1:8080/core/themes/stable9/css/system/components/ajax-progress.module.css", "X-Robots-Tag"),
		hasResponseHeader("http://127.0.0.1:8080/core/themes/stable9/css/foo", "X-Robots-Tag"),
		hasResponseHeader("http://127.0.0.1:8080/admin", "X-Robots-Tag"),
		hasResponseHeader("http://127.0.0.1:8080/admin/people", "X-Robots-Tag"),
		// Test for header: Feature-Policy.
		hasResponseHeader("http://127.0.0.1:8080", "Feature-Policy"),
		hasResponseHeader("http://127.0.0.1:8080/index.PHP", "Feature-Policy"),
		// Test for header: Strict-Transport-Security.
		hasResponseHeader("http://127.0.0.1:8080", "Strict-Transport-Security"),
		hasResponseHeader("http://127.0.0.1:8080/foo", "Strict-Transport-Security"),
		// Blocking rules.
		hasStatusCode("http://127.0.0.1:8080/index.PHP", 403),
		hasStatusCode("http://127.0.0.1:8080/tag", 200),
		hasStatusCode("http://127.0.0.1:8080/Tag", 404),
		hasStatusCode("http://127.0.0.1:8080/data.log", 404),
		// Static status codes.
		hasStatusCode("http://127.0.0.1:8080/core/README.md", 403),
		hasStatusCode("http://127.0.0.1:8080/core/CHANGELOG.txt", 403),
		hasStatusCode("http://127.0.0.1:8080/core/MAINTAINERS.txt", 403),
		hasStatusCode("http://127.0.0.1:8080/core/package.json", 403),
		hasStatusCode("http://127.0.0.1:8080/core/yarn.lock", 403),
		hasStatusCode("http://127.0.0.1:8080/modules/contrib/test/CHANGELOG.txt", 404),
		hasStatusCode("http://127.0.0.1:8080/modules/contrib/test/LICENSE.txt", 404),
		hasStatusCode("http://127.0.0.1:8080/modules/contrib/test/README.txt", 404),
		hasStatusCode("http://127.0.0.1:8080/modules/contrib/test/README.md", 404),
		hasStatusCode("http://127.0.0.1:8080/modules/contrib/test/TEST.txt", 200), // This is to ensure we are targetting file in the directory correctly.
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

// Check if a url has a specified header.
func hasResponseHeader(url, header string) Test {
	return func() error {
		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			return fmt.Errorf("failed to create request: %w", err)
		}

		// Mimic CloudFront behavior by setting the CloudFront-Forwarded-Proto header.
		req.Header.Set("CloudFront-Forwarded-Proto", "https")

		client := &http.Client{}
		resp, err := client.Do(req)
		if err != nil {
			return fmt.Errorf("failed to get host: %w", err)
		}
		defer resp.Body.Close()

		if _, ok := resp.Header[header]; !ok {
			return fmt.Errorf("header %s does not exist for page %s", header, url)
		}

		return nil
	}
}

// Check if a url does not have a specified header.
func noResponseHeader(url, header string) Test {
	return func() error {
		resp, err := http.Get(url)
		if err != nil {
			return fmt.Errorf("failed to get host: %w", err)
		}

		if _, ok := resp.Header[header]; ok {
			return fmt.Errorf("header %s does exist for page %s", url, header)
		}

		return nil
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
