{
  lib,
  pkgs,
  ...
}: {
  home.packages = [pkgs.vlc];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.genAttrs [
      "application/ogg"
      "application/vnd.apple.mpegurl"
      "application/vnd.ms-wpl"
      "application/vnd.rn-realmedia"
      "application/vnd.rn-realmedia-vbr"
      "application/x-flac"
      "application/x-matroska"
      "application/x-ogg"
      "application/xspf+xml"
      "audio/aac"
      "audio/ac3"
      "audio/flac"
      "audio/m4a"
      "audio/mp4"
      "audio/mpeg"
      "audio/mpegurl"
      "audio/ogg"
      "audio/opus"
      "audio/vnd.rn-realaudio"
      "audio/vorbis"
      "audio/wav"
      "audio/webm"
      "audio/x-aac"
      "audio/x-aiff"
      "audio/x-flac"
      "audio/x-m4a"
      "audio/x-matroska"
      "audio/x-mpegurl"
      "audio/x-ms-wma"
      "audio/x-pn-realaudio"
      "audio/x-scpls"
      "audio/x-speex"
      "audio/x-vorbis+ogg"
      "audio/x-wav"
      "video/3gpp"
      "video/3gpp2"
      "video/avi"
      "video/mp2t"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/quicktime"
      "video/vnd.mpegurl"
      "video/webm"
      "video/x-flv"
      "video/x-m4v"
      "video/x-matroska"
      "video/x-ms-asf"
      "video/x-ms-wmv"
      "video/x-msvideo"
      "video/x-ogm+ogg"
      "video/x-theora+ogg"
    ] (_: "vlc.desktop");
  };
}
