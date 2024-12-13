{
  description = "MELFA ROS 2 Driver";

  inputs = {
    ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs.follows = "ros-overlay/nixpkgs";
  };

  # Add to nix.conf or system configuration for caching:
  # trusted-public-keys = "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=";
  # substituters = "https://ros.cachix.org";

  outputs = { self, nixpkgs, ros-overlay, ... }:
    let
      forAllSystems = (f: nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
          ros-distro = pkgs.rosPackages.jazzy;
          packages = self.packages.${system};
        in
        f {
          inherit system pkgs ros-distro packages;
        })
      );
    in
    {
      overlays.default = (nixpkgs.lib.composeManyExtensions [
        ros-overlay.overlays.default
      ]);

      packages = forAllSystems
        ({ ros-distro, ... }: {
          inherit (ros-distro) moveit-ros-move-group;
        });
    };
}
