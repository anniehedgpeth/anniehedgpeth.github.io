# run test on remote host on SSH
inspec exec test.rb -t ssh://user@hostname -i /path/to/key

# run test on remote host using SSH agent private key authentication. Requires InSpec 1.7.1
inspec exec test.rb -t ssh://user@hostname

The public key must be set in ~/.ssh/authorized_keys on the server. See https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server

If you use ssh-add InSpec can pick up your local ssh config as well.

# this will add ssh private key to local ssh
ssh-add
# now log into the machine via
ssh annie@mc-inspec.southcentralus.cloudapp.azure.com
# now with inspec, no key parameter required anymore, inspec uses the key from native ssh
inspec exec https://github.com/anniehedgpeth/inspec-presentation -t ssh://annie@mc-inspec.southcentralus.cloudapp.azure.com
—

Copying your Public Key Manually

If you do not have password-based SSH access to your server available, you will have to do the above process manually.

The content of your id_rsa.pub file will have to be added to a file at ~/.ssh/authorized_keys on your remote machine somehow.

To display the content of your id_rsa.pub key, type this into your local computer:

cat ~/.ssh/id_rsa.pub
You will see the key's content, which may look something like this:

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqql6MzstZYh1TmWWv11q5O3pISj2ZFl9HgH1JLknLLx44+tXfJ7mIrKNxOOwxIxvcBF8PXSYvobFYEZjGIVCEAjrUzLiIxbyCoxVyle7Q+bqgZ8SeeM8wzytsY+dVGcBxF6N4JS+zVk5eMcV385gG3Y6ON3EG112n6d+SMXY0OEBIcO6x+PnUSGHrSgpBgX7Ks1r7xqFa7heJLLt2wWwkARptX7udSq05paBhcpB0pHtA1Rfz3K2B+ZVIpSDfki9UVKzT8JUmwW6NNzSgxUfQHGwnW7kj4jp4AT0VZk3ADw497M2G/12N0PPB5CnhHf7ovgy6nL1ikrygTKRFmNZISvAcywB9GVqNAVE+ZHDSCuURNsAInVzgYo9xgJDW8wUw2o8U77+xiFxgI5QSZX3Iq7YLMgeksaO4rBJEa54k8m5wEiEE1nUhLuJ0X/vh2xPff6SQ1BL/zkOhvJCACK6Vb15mDOeCSq54Cr7kvS46itMosi/uS66+PujOO+xt/2FWYepz6ZlN70bRly57Q06J+ZJoc9FfBCbCyYH7U/ASsmY095ywPsBo1XQ9PqhnN1/YOorJ068foQDNVpm146mUpILVxmq41Cj55YKHEazXGsdBIbXWhcrRf4G2fJLRcGUr9q8/lERo9oxRm5JFX6TCmj6kmiFqv+Ow9gI0x8GvaQ== demo@test
Access your remote host using whatever method you have available. For instance, if your server is a DigitalOcean Droplet, you can log in using the web console in the control panel:

DigitalOcean console access

Once you have access to your account on the remote server, you should make sure the ~/.ssh directory is created. This command will create the directory if necessary, or do nothing if it already exists:

mkdir -p ~/.ssh
Now, you can create or modify the authorized_keys file within this directory. You can add the contents of your id_rsa.pub file to the end of the authorized_keys file, creating it if necessary, using this:

echo public_key_string >> ~/.ssh/authorized_keys
In the above command, substitute the public_key_string with the output from the cat ~/.ssh/id_rsa.pub command that you executed on your local system. It should start with ssh-rsa AAAA....

If this works, you can move on to try to authenticate without a password.

Authenticate to your Server Using SSH Keys
If you have successfully completed one of the procedures above, you should be able to log into the remote host without the remote account's password.

The basic process is the same:

ssh username@remote_host
If this is your first time connecting to this host (if you used the last method above), you may see something like this:

The authenticity of host '111.111.11.111 (111.111.11.111)' can't be established.
ECDSA key fingerprint is fd:fd:d4:f9:77:fe:73:84:e1:55:00:ad:d6:6d:22:fe.
Are you sure you want to continue connecting (yes/no)? yes
This just means that your local computer does not recognize the remote host. Type "yes" and then press ENTER to continue.

If you did not supply a passphrase for your private key, you will be logged in immediately. If you supplied a passphrase for the private key when you created the key, you will be required to enter it now. Afterwards, a new shell session should be spawned for you with the account on the remote system.

If successful, continue on to find out how to lock down the server.