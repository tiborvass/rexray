set -e
docker rm -vf rexray || true
cat Dockerfile | docker build -t tiborvass/rexray-plugin-image -
docker create --name rexray tiborvass/rexray-plugin-image
rm -rf /tmp/rexray
mkdir -p /tmp/rexray/rootfs
docker export -o /tmp/rexray/rexray.tar rexray
( cd /tmp/rexray/rootfs && tar xf ../rexray.tar )
cat <<EOF > /tmp/rexray/config.json
{
      "Args": {
        "Description": "",
        "Name": "",
        "Settable": null,
        "Value": null
      },
      "Description": "A rexray volume plugin for Docker",
      "Documentation": "https://docs.docker.com/engine/extend/plugins/",
      "Entrypoint": [
        "/usr/bin/rexray", "service", "start", "-f"
      ],
      "Env": [
        {
          "Description": "",
          "Name": "REXRAY_SERVICE",
          "Settable": [
            "value"
          ],
          "Value": "ebs"
        },
        {
          "Description": "",
          "Name": "EBS_ACCESSKEY",
          "Settable": [
            "value"
          ],
          "Value": ""
        },
        {
          "Description": "",
          "Name": "EBS_SECRETKEY",
          "Settable": [
            "value"
          ],
          "Value": ""
        }
      ],
      "Interface": {
        "Socket": "rexray.sock",
        "Types": [
          "docker.volumedriver/1.0"
        ]
      },
      "Linux": {
        "AllowAllDevices": true,
        "Capabilities": ["CAP_SYS_ADMIN"],
        "Devices": null
      },
      "Mounts": [
        {
          "Source": "/dev",
          "Destination": "/dev",
          "Type": "bind",
          "Options": ["rbind"]
        }
      ],
      "Network": {
        "Type": "host"
      },
      "PropagatedMount": "/var/lib/libstorage/volumes",
      "User": {},
      "WorkDir": ""
}
EOF
docker plugin create tiborvass/rexray-plugin /tmp/rexray
