class XpressIdevicesyslog < Formula
  desc "Idevicesyslog (libimobiledevice 1.4.0) with the upstream memory-leak fix"
  homepage "https://libimobiledevice.org/"
  url "https://github.com/libimobiledevice/libimobiledevice/releases/download/1.4.0/libimobiledevice-1.4.0.tar.bz2"
  sha256 "23cc0077e221c7d991bd0eb02150a0d49199bcca1ddf059edccee9ffd914939d"
  license "LGPL-2.1-or-later"

  depends_on "pkgconf" => :build
  depends_on "libimobiledevice-glue"
  depends_on "libplist"
  depends_on "libtasn1"
  depends_on "libtatsu"
  depends_on "libusbmuxd"
  depends_on "openssl@3"

  # "ostrace: Fix memory leak (#1677)" (upstream commit 5ca453f, merged 2026-05-21, not in a release yet). Without it
  # idevicesyslog (os_trace_relay, its default mode since 1.4.0) keeps every log message it receives: measured ~2.4 MB
  # of memory per MB of log, i.e. 500 MB about four minutes into a test on a busy iPhone. With it, memory stays flat
  # (~3.5 MB). The one-line patch is kept below __END__ so an install needs no second download.
  patch :DATA

  def install
    # Link the library into the tool statically, so the fix can't be shadowed by Homebrew's shared 1.4.0 library,
    # and install only the renamed tool: nothing clashes with the libimobiledevice formula. The device agent's iOS
    # capture runs only `xpress-idevicesyslog`; its update installs this formula.
    system "./configure", "--disable-silent-rules", "--without-cython", "--disable-shared", "--enable-static",
                          "--prefix=#{prefix}"
    system "make"
    bin.install "tools/idevicesyslog" => "xpress-idevicesyslog"
  end

  test do
    assert_match "--syslog-relay", shell_output("#{bin}/xpress-idevicesyslog --help 2>&1")
  end
end

__END__
diff --git a/src/ostrace.c b/src/ostrace.c
index 68eb6bf1b3644b59fcf460af9d7f0a19e107168a..c73ee7fc2f1827ff8e278cee05ea90217b532274 100644
--- a/src/ostrace.c
+++ b/src/ostrace.c
@@ -251,6 +251,7 @@ void *ostrace_worker(void *arg)
 			break;
 		}
 		oswt->cbfunc(buf, received, oswt->user_data);
+		free(buf);
 	}
 
 	if (oswt) {
