M = $(shell printf "\033[34;1m▶\033[0m")

bundler: ; $(info $(M) Installing Bundler…)
	gem install bundler
	
deps: bundler; $(info $(M) Installing Gems…)
	bundle install

clean: ; $(info $(M) Cleaning…)
	xcodebuild -project TheSportsDB.xcodeproj -scheme TheSportsDB clean | xcpretty

.PHONY: deps clean
