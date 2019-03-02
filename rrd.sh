#! /bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OUT_DIR=/var/www/html/greenhouse
mkdir -p $OUT_DIR

DATA_DIR=/var/run/greenhouse
mkdir -p $DATA_DIR

GRAPH_PERIOD=1
PERIODS="hour day week month year"
RRA_DEF="RRA:AVERAGE:0.5:1:120 RRA:AVERAGE:0.5:5:576 RRA:AVERAGE:0.5:30:672 RRA:AVERAGE:0.5:120:744 RRA:AVERAGE:0.5:1440:732 RRA:MAX:0.5:1:120 RRA:MAX:0.5:5:576 RRA:MAX:0.5:30:672 RRA:MAX:0.5:120:744 RRA:MAX:0.5:1440:732"
HEARTBEAT=300
WIDTH=620
HEIGHT=280
#OPTIONS=" --only-graph"
OPTIONS=""
case $1 in
	create)
		rrdtool create $DATA_DIR/greenhouse.rrd \
			--step 60 --no-overwrite \
			DS:TEMP:GAUGE:$HEARTBEAT:0:U  \
			DS:HUMID:GAUGE:$HEARTBEAT:0:U  \
			$RRA_DEF
		;;
	update)
		rrdtool update $DATA_DIR/greenhouse.rrd `python $THIS_DIR/getTemp.py`
	;;
	graph)
		for PERIOD in $PERIODS
		do
			rrdtool graph $OUT_DIR/temp-$PERIOD.png \
				--start now-${GRAPH_PERIOD}$PERIOD \
				--vertical-label "Temperature C" \
				--title "measurements for the last $PERIOD" \
				--width ${WIDTH} \
				--height ${HEIGHT} \
				--lower-limit 0 \
				--rigid \
				--alt-autoscale ${OPTIONS} \
				DEF:TEMP=$DATA_DIR/greenhouse.rrd:TEMP:AVERAGE \
				DEF:HUMID=$DATA_DIR/greenhouse.rrd:HUMID:AVERAGE \
				LINE:TEMP#660000:"Temperature\t" \
				GPRINT:TEMP:AVERAGE:"Avg\:%4.2lf" \
				GPRINT:TEMP:MAX:"Max\:%4.2lf" \
				GPRINT:TEMP:MIN:"Min\:%4.2lf\n" \
				LINE:HUMID#0000cc:"Humidity\t" \
				GPRINT:HUMID:AVERAGE:"Avg\:%4.2lf" \
				GPRINT:HUMID:MAX:"Max\:%4.2lf" \
				GPRINT:HUMID:MIN:"Min\:%4.2lf\n" \
				COMMENT:"Greenhouse\l" \
				COMMENT:"\u" \
				COMMENT:"`date | sed "s/\:/\\\\\:/g"`\r" > /dev/null
		done
	;;
esac