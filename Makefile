NAME = mrmagooey/aggressive-squid-cache
VERSION = 0.1.0

BENCHMARK_NETWORK = bench-net
BENCHMARK_CONTAINER_NAME=squid
BENCHMARK_CONTAINER_PORT=3128

.PHONY: all build setup_benchmark benchmark_apt_update benchmark_apt_install benchmark_npm_install

all: build

build:
ifneq ($(and $(DOCKER_BUILD_NETWORK),$(DOCKER_BUILD_PROXY)),)
	docker build -t $(NAME):$(VERSION) .
else
	docker build -t $(NAME):$(VERSION) --network $(DOCKER_BUILD_NETWORK) --build-arg http_proxy=$(DOCKER_BUILD_PROXY) .
endif

benchmarks: benchmark_apt_update benchmark_apt_install benchmark_yum_update benchmark_yum_install benchmark_npm_install

setup_benchmark=./benchmarks/setup_benchmark.sh

build_apt_update_container=time docker build -q --no-cache --network $(BENCHMARK_NETWORK) --build-arg http_proxy=http://$(BENCHMARK_CONTAINER_NAME):$(BENCHMARK_CONTAINER_PORT) -f benchmarks/apt-update-benchmark .

benchmark_apt_update:
	$(call setup_benchmark)
	echo "\nFirst run benchmark_apt_update, squid cache should be empty"
	$(call build_apt_update_container)
	echo "\nSecond run benchmark_apt_update, squid cache should be populated"
	$(call build_apt_update_container)

build_apt_install_container=time docker build -q --no-cache --network $(BENCHMARK_NETWORK) --build-arg http_proxy=http://$(BENCHMARK_CONTAINER_NAME):$(BENCHMARK_CONTAINER_PORT) -f benchmarks/apt-install-benchmark .

benchmark_apt_install:
	$(call setup_benchmark)
	echo "\nFirst run benchmark_apt_install, squid cache should be empty"
	$(call build_apt_install_container)
	echo "\nSecond run benchmark_apt_install, squid cache should be populated"
	$(call build_apt_install_container)

build_yum_update_container=time docker build -q --no-cache --network $(BENCHMARK_NETWORK) --build-arg http_proxy=http://$(BENCHMARK_CONTAINER_NAME):$(BENCHMARK_CONTAINER_PORT) -f benchmarks/yum-update-benchmark .

benchmark_yum_update:
	$(call setup_benchmark)
	echo "\nFirst run benchmark_yum_update, squid cache should be empty"
	$(call build_yum_update_container)
	echo "\nSecond run benchmark_yum_update, squid cache should be populated"
	$(call build_yum_update_container)

build_yum_install_container=time docker build -q --no-cache --network $(BENCHMARK_NETWORK) --build-arg http_proxy=http://$(BENCHMARK_CONTAINER_NAME):$(BENCHMARK_CONTAINER_PORT) -f benchmarks/yum-install-benchmark .

benchmark_yum_install:
	$(call setup_benchmark)
	echo "\nFirst run benchmark_yum_install, squid cache should be empty"
	$(call build_yum_install_container)
	echo "\nSecond run benchmark_yum_install, squid cache should be populated"
	$(call build_yum_install_container)

build_npm_install_container=time docker build -q --no-cache --network $(BENCHMARK_NETWORK) --build-arg http_proxy=http://$(BENCHMARK_CONTAINER_NAME):$(BENCHMARK_CONTAINER_PORT) -f benchmarks/npm-install-benchmark .

benchmark_npm_install:
	$(call setup_benchmark)
	echo "\nFirst run benchmark_npm_install, squid cache should be empty"
	$(call build_npm_install_container)
	echo "\nSecond run benchmark_npm_install, squid cache should be populated"
	$(call build_npm_install_container)
