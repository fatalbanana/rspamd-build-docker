# Fedora with runtime dependencies for rspamd
ARG  FEDORA_VERSION=29
FROM fedora:${FEDORA_VERSION}

# rspamd runtime dependencies:
#   file-libs
#   glib2
#   libevent
#   libicu
#   luajit
#   openssl-libs
#   pcre
#   sqlite-libs
#   hyperscan/vectorscan

# tools;
#   dnf-plugins-core - for yum debuginfo-install
#   gdb
#   llvm - for llvm-symbolizer

RUN set -x; \
	yum -qy --setopt install_weak_deps=False upgrade-minimal && \
	yum  -y --setopt install_weak_deps=False install \
		dnf-plugins-core gdb llvm \
		file-libs glib2 libevent libicu libsodium luajit openssl-libs pcre sqlite-libs && \
	yum -qy --setopt install_weak_deps=False debuginfo-install \
		glibc glib2 libsodium luajit hyperscan && \
	yum -qy remove dnf-plugins-core && \
	sysArch="$(uname -m)" && \
	case "$sysArch" in \
		amd64) \
			yum  -y --setopt install_weak_deps=False install hyperscan ; \
			;; \
		aarch64) \
			rm -fr /vectorscan-src/ /vectorscan ; \
			yum  -y --setopt install_weak_deps=False install boost-devel git python3-devel && \
                        git clone https://github.com/VectorCamp/vectorscan --depth 1 --branch vectorscan/5.4.9 /vectorscan-src && \
                        (cd /vectorscan-src ; mkdir build ; cd build ; cmake .. -DCMAKE_C_COMPILER="$c_compiler" -DCMAKE_CXX_COMPILER="$cxx_compiler" -DCMAKE_INSTALL_PREFIX=/vectorscan -DCMAKE_BUILD_TYPE=Release -DFAT_RUNTIME=ON -DCMAKE_C_FLAGS="-fpic -fPIC" -DCMAKE_CXX_FLAGS="-fPIC -fpic" -DPCRE_SUPPORT_LIBBZ2=OFF; make -j4 ; make install) ; \
                        rm -fr /vectorscan-src/ ; \
                        ;; \
                *) \
                        ;; \
        esac

	rm /var/log/*.log && rm -r /var/cache/dnf

USER nobody
