{ config, lib, ... }:

{
  options.services.campground.hub = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption { type = lib.types.str; };
        path = lib.mkOption { type = lib.types.str; };
        port = lib.mkOption { type = lib.types.int; };
        emoji = lib.mkOption { type = lib.types.str; default = "📦"; };
        description = lib.mkOption { type = lib.types.str; default = ""; };
      };
    });
    default = [];
    description = "List of services to automatically reverse-proxy and add to the dashboard landing page.";
  };
}
