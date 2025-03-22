{ pkgs, lib, var, ... }:

let

  netName = {
         wifi = "MEO-2A9CE0";
         ether = "enp8s0";
  };
  hostid = "007f0200";
  password = "b159bff499";

  devices = {
    wifi = "wlp7s0";
    ether = "enp8s0";
  };

  subnet =  {
        v4 = "24";
        v6 = "64";
  };

  ip = {
        v4 = {
          wifi = {
            address = "192.168.1.80";
            gateway = "192.168.1.254";
          };
          ether = {
            address = "192.168.1.84";
            gateway = "192.168.1.255";
          };
        };

        v6 = {

          wifi = {
            address = "2001:8a0:64bc:9500:16b2:1f15:69f0:7825";
            gateway = "fe80::5442:3dd3:ab0f:407b";
          };

          ether = {
            address = "2001:8a0:64bc:9500:8e7d:919d:428c:4bf2";
            gateway = "fe80::1e57:3eff:fe2a:9cdf";
            own = "2001:8a0:64bc:9500:8e7d:919d:428c:4bf2";
          };
        };

        loop = "127.0.0.1";
    };

  network = {
        v4 = (ip.v4.wifi.address + "/" + subnet.v4);
        v6 = (ip.v6.wifi.address + "/" + subnet.v6);
   };
  own_ip =  (ip.v6.own + "/" + subnet.v6);
in

{

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
    nftables.enable = true;
    wireless.networks = {
      "${netName.wifi}" = {
        psk = "b159bff499";
      };
    };
  };
  systemd.services.NetworkManager = {
    wantedBy = [ "network.target" ];
  };

 systemd.network = {
  enable = true;

  networks."${devices.wifi}" = {

  matchConfig.Name = "${devices.wifi}";

  address = [
   # Configure addresses including subnet mask
   "${network.v4}"
   "${network.v6}"
  ];

  routes = [
   # Create default routes for both IPv6 and IPv4
   { Gateway = "${ip.v4.wifi.gateway}"; }
   { Gateway = "${ip.v6.wifi.gateway}"; }

   # Or when the gateway is not on the same network
   {
    Gateway = "172.31.1.1";
    GatewayOnLink = true;
   }
  ];
     # Make the routes on this interface a dependency for network-online.target
     linkConfig.RequiredForOnline = "routable";
   };
 };
}
