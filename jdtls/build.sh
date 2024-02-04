#! /bin/env bash


announce() {
	local text_bold="\e[1m"
	local text_reset="\e[0m"
	echo -e "${text_bold}$1$text_reset"
}

# test for git + jdk>=17 being installed

script_dir=$(dirname "$0")

cd $script_dir

git_dir="eclipse.jdt.ls"

announce "Cleaning up old source directory..."

rm -rf repository/

announce "Downloading source..."

git clone https://github.com/eclipse-jdtls/eclipse.jdt.ls.git $git_dir

cd $git_dir

announce "Building..."

if [[ $1 == "--test" ]]; then
	./mvnw clean verify
else
	echo no test
	./mvnw clean verify -DskipTests=true
fi

cd ..

announce "Copying result to $script_dir/respository/..."

mv "$git_dir/org.eclipse.jdt.ls.product/target/repository/" .

announce "Cleaning up..."

rm -rf "$git_dir"

announce "All done!"
