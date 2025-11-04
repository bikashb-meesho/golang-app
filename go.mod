module github.com/bikashb-meesho/golang-app

go 1.23

require (
	github.com/bikashb-meesho/golang-lib v1.0.0
	go.uber.org/zap v1.27.0
)

require go.uber.org/multierr v1.11.0 // indirect

// For local development with the library
replace github.com/bikashb-meesho/golang-lib => ../golang-lib
