.phony: build
build: configure.done
	obuild build

configure.done: stars.obuild
	obuild configure
	touch configure.done

.phony: clean
clean:
	rm -rf dist configure.done
