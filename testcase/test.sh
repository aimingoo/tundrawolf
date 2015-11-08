# ---------------------------------------------------------------------------------------------------------
#  A tiny demo only
# 
# Usage:
#	> git clone https://github.com/aimingoo/tundrawolf ~/tundrawolf
#	> sudo ${NGINX_HOME}/sbin/nginx -p "${HOME}/tundrawolf/nginx"
#	> bash ~/tundrawolf/testcase/test.sh
# ---------------------------------------------------------------------------------------------------------

f_dir=$(dirname $(dirname $(realpath $0)))
f_sample="${f_dir}/infra/samples/taskDef.json"
task1=`curl -s -XPOST 'http://localhost/register' --data-binary @"$f_sample" | sed -re 's/^"|"$//g'`

# taskDef='{ "xx": {"map": "'${task1}'", "arguments": {"method": "POST", "args": "y=maped"}, "scope": "test:local:*"} }'
taskDef='{ "xx": {"map": "'${task1}'", "arguments": {"method": "POST", "args": {"y": "maped"}}, "scope": "test:local:*"} }'
task2=`echo "$taskDef" | curl -s -XPOST 'http://localhost/register' --data-binary @- | sed -re 's/^"|"$//g'`

echo "$task1 registed"
echo "$task2 registed"

echo
echo "execute $task1"
curl -s -XPOST "http://localhost/execute?${task1}" --data 'y=aimingoo'

echo
echo "execute $task2"
curl -s -XPOST "http://localhost/execute?${task2}"
