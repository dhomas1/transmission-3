### ZLIB ###
_build_zlib() {
local VERSION="1.3"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}" --libdir="${DEST}/lib" --shared
make
make install
popd
}

### OPENSSL ###
_build_openssl() {
local VERSION="1.1.1u"
local FOLDER="openssl-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://www.openssl.org/source/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./Configure --prefix="${DEPS}" --openssldir="${DEST}/etc/ssl" \
  zlib-dynamic --with-zlib-include="${DEPS}/include" --with-zlib-lib="${DEPS}/lib" \
  shared threads linux-armv4 -DL_ENDIAN ${CFLAGS} ${LDFLAGS} \
  -Wa,--noexecstack -Wl,-z,noexecstack
sed -i -e "s/-O3//g" Makefile
make
make install_sw
mkdir -p "${DEST}/libexec"
cp -vfa "${DEPS}/bin/openssl" "${DEST}/libexec/"
cp -vfa "${DEPS}/lib/libssl.so"* "${DEST}/lib/"
cp -vfa "${DEPS}/lib/libcrypto.so"* "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/engines"* "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/pkgconfig" "${DEST}/lib/"
rm -vf "${DEPS}/lib/libcrypto.a" "${DEPS}/lib/libssl.a"
sed -e "s|^libdir=.*|libdir=${DEST}/lib|g" -i "${DEST}/lib/pkgconfig/libcrypto.pc"
sed -e "s|^libdir=.*|libdir=${DEST}/lib|g" -i "${DEST}/lib/pkgconfig/libssl.pc"
popd
}

### CURL ###
_build_curl() {
local VERSION="8.2.1"
local FOLDER="curl-8_2_1"
local FILE="curl-${VERSION}.tar.gz"
local URL="https://github.com/curl/curl/releases/download/${FOLDER}/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" \
  --libdir="${DEST}/lib" --disable-static \
  --disable-debug --disable-curldebug \
  --with-zlib="${DEPS}" --with-ssl="${DEPS}" --with-random \
  --with-ca-bundle="${DEST}/etc/ssl/certs/ca-certificates.crt" --enable-ipv6
make
make install
popd
}

### LIBEVENT ###
_build_libevent() {
local VERSION="2.1.22-stable"
local FOLDER="libevent-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://github.com/libevent/libevent/releases/download/release-${VERSION}/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" \
  --libdir="${DEST}/lib" --disable-static
make
make install
popd
}

### TRANSMISSION ###
_build_transmission() {
local VERSION="3.00"
local FOLDER="transmission-${VERSION}"
local FILE="${FOLDER}.tar.xz"
local URL="https://github.com/transmission/transmission/releases/download/${VERSION}/${FILE}"

_download_xz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PKG_CONFIG_PATH="${DEST}/lib/pkgconfig" \
  ./configure --host="${HOST}" --prefix="${DEST}" \
  --disable-nls --enable-cli --enable-daemon --enable-utp \
  --with-zlib="${DEPS}"
make -j1
make -j1 install
mv -v "${DEST}/share/transmission/web" "${DEST}/app"
popd
}

_build() {
  _build_zlib
  _build_openssl
  _build_curl
  _build_libevent
  _build_transmission
  _package
}
