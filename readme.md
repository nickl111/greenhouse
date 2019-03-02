# Monitor the greenhouse

Install:
`apt-get install apache2 rrdtool bc`


Put this in the cron:

```
*/1 * * * * bash /root/greenhouse/rrd.sh update
*/1 * * * * bash /root/greenhouse/rrd.sh graph
```

Go here:

http://127.0.0.1/greenhouse/