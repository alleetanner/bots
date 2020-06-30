# Script to check if mongod is up as a proxy of if a harvest is in progress.

# post if user ctrl-c
trap ctrl_c INT
function ctrl_c() {
    curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: BozBot down, user interrupt."}' https://YOUR_SLACK_WEBHOOK
    exit 0;
}

# post that bozbot is up
curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: BozBot up."}' https://YOUR_SLACK_WEBHOOK

# set booleans, toggled to stop repeated posts when nothing has changed.
running=0;
up=0;
while true;
do
    if [ `pgrep mongod | wc -l` == 0 ] && [ $running == 1 ] 
    then
        if [ `pgrep epicosm_ | wc -l` == 0 ]
            then
                # catch if goes down while harvesting
                curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: epicosm looks down, interrupted while active."}' https://YOUR_SLACK_WEBHOOK
                up=0;
            else
                # catch when harvest finished
                curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: epicosm harvest finished, waiting for next harvest."}' https://YOUR_SLACK_WEBHOOK
        fi
        running=0;
    elif [ `pgrep mongod | wc -l` != 0 ] && [ $running == 0 ]
        then
            # catch harvest start
            curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: epicosm harvest started."}' https://YOUR_SLACK_WEBHOOK
            running=1;
            up=1;
    elif [ `pgrep epicosm_ | wc -l` == 0 ] && [ $running == 0 ] && [ $up == 1 ]
        then
            # catch if goes down while NOT harvesting
            curl -X POST -H 'Content-type: applicati/json' --data '{"text":"IEUVM: epicosm looks down, interrupted while idle."}' https://YOUR_SLACK_WEBHOOK
        up=0;
    fi
    sleep 60; # check status once a minute
done

