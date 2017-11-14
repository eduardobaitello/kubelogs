# kubelogs
Kubelogs is a bash script that uses your current `kubectl context` to navigate through namespaces, pods and containers, saving their logs to a local text file.

## Usage
Just use `kubelogs` and navigate through the options to choose your container. Once select, type the output local directory to save the `.log` text file.  
The output file will be created with the name `POD_CONTAINER_TIMESTAMP.log` .

### Example

```
$ kubelogs
Choose a namespace:
1) some-namepace
2) default
3) kube-public
4) kube-system
5) CANCEL
Namespace: 4
Namespace selected is kube-system

Choose a pod:
1) kube-dns-2049707976-w48vz
2) kubernetes-dashboard-2917854236-m4fgx
3) tiller-deploy-1651596238-xfzcf
4) CANCEL
Pod: 1
Pod selected is kube-dns-2049707976-w48vz

Choose a container:
1) kubedns	    3) dnsmasq-metrics	5) CANCEL
2) dnsmasq	    4) healthz
Container: 3
Container selected is dnsmasq-metrics

Type a local directory for output file: /tmp
Log file saved in /tmp/kube-dns-2049707976-w48vz_dnsmasq-metrics_20171113_212706.log
```

Optionally, the `--namespace` flag can be used with `kubelogs` to skip the interactive namespace selection.

Use `kubelogs --help` for help and additional options.
