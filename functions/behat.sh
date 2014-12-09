#!/bin/bash
# @file
# Common functionality for setting up behat.

#
# Ensures that xvfb is started.
#
function drupal_ti_ensure_xvfb() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-xvfb-running" ]
	then
		return
	fi

	# Run a virtual frame buffer server.
        /usr/bin/Xvfb $DISPLAY -ac -screen 0 "$DRUPAL_TI_BEHAT_SCREENSIZE_COLOR" &
	sleep 3

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-xvfb-running"
}

#
# Ensures that selenium is running.
#
function drupal_ti_ensure_selenium() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-selenium-running" ]
	then
		return
	fi

	cd "$TRAVIS_BUILD_DIR/.."
	mkdir -p selenium-server
	cd selenium-server

	# @todo Make whole file URL overridable via defaults based on env.
	wget "http://selenium-release.storage.googleapis.com/$DRUPAL_TI_BEHAT_SELENIUM_VERSION/selenium-server-standalone-$DRUPAL_TI_BEHAT_SELENIUM_VERSION.0.jar"
	java -jar "selenium-server-standalone-$DRUPAL_TI_BEHAT_SELENIUM_VERSION.0.jar" &
        until netstat -an 2>/dev/null | grep -q "4444.*LISTEN"
        do
                sleep 1
        done

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-selenium-running"
}

#
# Replaces behat.yml from behat.yml.dist
#
function drupal_ti_replace_behat_vars() {
	# Create a dynamic script.
	{
		echo "#!/bin/bash"
		echo "cat <<EOF > behat.yml"
		# @todo Make filename configurable.
		cat "$DRUPAL_TI_BEHAT_YML"
		echo "EOF"
	} >> .behat.yml.sh

	# Execute the script.
	. .behat.yml.sh
}
