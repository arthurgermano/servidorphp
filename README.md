# servidorphp
Docker file for the image with the same name of the repository

Server Apache 2+

Installed PHP 5.5.9 Oracle 11.2 MSSQL PostgreSQL Phalcon 2.0.13 Redis 2.* 

To RUN docker container run -d --name test --network host -v $(pwd):/var/www/html arthurgermano/servidorphp 
-d: Detached 
--name: Name of the container 
--network: 'host' to use the same network of the local machine 
-v: Volume, where is you code to map to apache container, ($pwd) - Present Work Directory

To EXEC the image bash and run commands inside of the container 
docker container exec -it test bash

If you're using proxy you must, inside of the container, export http_proxy=http://localhost:8118 - privoxy example 

To BUILD the image Docker file is in: https://github.com/arthurgermano/servidorphp/blob/master/Dockerfile 
The files to configure are in the same repository.

Execute the command in the folder where the dockerfile is! 

docker image build --build-arg http_proxy=http://localhost:8118 --network host --tag servidorphp . 
--build-arg: passing environment variables to the building image, in this case proxy of privoxy on localmachine 
--network: 'host' to use the same network as the localmachine 
--tag: name of the image .: Use dot to refer to local folder, or use the path where the dockerfile is.

This image created, has all the files needed inside of the /tmp directory of the container. Left on purpose just in case we might need in the future!
