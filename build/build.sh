docker build -t cardano .

id=$(docker create cardano)
mkdir -p rpms
docker cp $id:/root/rpmbuild/RPMS/x86_64 rpms
docker rm -v $id
