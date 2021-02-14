#!/bin/bash





createNodes() {
	nb_machine=1
	[ "$1" != "" ] && nb_machine=$1
	# setting min/max
	min=1
	max=0

	idmax=`docker ps -a --format '{{ .Names}}' | awk -F "-" -v user="$USER" '$0 ~ user"-debian" {print $3}' | sort -r |head -1`
    echo "$idmax idmax"
	
	min=$(($idmax + 1))
	max=$(($idmax + $nb_machine))


	for i in $(seq $min $max);do
		docker run -tid --privileged --publish-all=true  --name $USER-debian-$i -h debian$i debian:buster
		#create an user and home user
        docker exec -ti $USER-debian-$i /bin/sh -c "useradd -m -p frparis92 $USER"
        # authenticate ssh
		docker exec -ti $USER-debian-$i /bin/sh -c "mkdir  ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && chown $USER:$USER $HOME/.ssh"
	    docker cp $HOME/.ssh/id_rsa.pub $USER-debian-$i:$HOME/.ssh/authorized_keys
	    docker exec -ti $USER-debian-$i /bin/sh -c "chmod 600 ${HOME}/.ssh/authorized_keys && chown $USER:$USER $HOME/.ssh/authorized_keys"
		docker exec -ti $USER-debian-$i /bin/sh -c "echo '$USER   ALL=(ALL) NOPASSWD: ALL'>>/etc/sudoers"
		docker exec -ti $USER-debian-$i /bin/sh -c "service ssh start"
		echo "Conteneur $USER-debian-$i created"
	done
	infosNodes	

}


dropNodes(){
	echo "delete all container..."
	docker rm -f $(docker ps -a | grep $USER-debian | awk '{print $1}')
	echo "end delete all"
}




#si option --create
if [ "$1" == "--create" ];then
	createNodes $2

# si option --drop
else [ "$1" == "--drop" ];
	dropNodes
fi