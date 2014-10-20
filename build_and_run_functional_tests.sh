#!/usr/bin/env bash
xctool.sh -workspace logger.xcworkspace -scheme logger -sdk iphonesimulator \
	clean \
	test -only StressTests:FunctionalTests/test_sending_metrics_over_http \
	test -only StressTests:FunctionalTests/test_connection_delegate_invokes_success_for_good_url
