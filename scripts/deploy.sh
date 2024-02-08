scp -i ../keys/infrastructure-20230105.pem ~/.ssh/github_id_rsa* ubuntu@35.88.114.83:~/
eval "$(ssh-agent -s)"
ssh-add github_id_rsa
git clone git@github.com:cbladd/generac_weather.git
cd generac_weather/
