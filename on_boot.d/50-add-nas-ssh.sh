#!/bin/bash

# Allow NAS' SSH key to login without password so it can perform automatic backups
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGlb5SZmgmKXxsXj1VlyERJNw5SoxYVMBetgpDzAQZwvzJKcGalluZNXXj/JCyCoZq+G3BSEH0bVqcV5jGp0HfQ8E2PnsLWEQSdtAR+SKpNnzM4twQqV519Jx2xZwAdL7qd1ClBPNg01dCHZ3+A0Oi/RLbS5xz8gW3FTr09roesi94or+i5GlU8POStx9fsLUDJpTH9xomGxF7fb4BDoemDAFo3bZiO3blr74IS3GDQ2aMe6AkdhvnozeaCREvXgOl6DzCniwWhQ7kipBEz7HjhnC51LqE8VBoQum0wL6OmjLrHnoP7DOVWc0CLWsjK6ripch99ZsdP+XaphLwZHxQ0DSvdIkbDIpoJBvsXIQWJBOddX5pHcVPgRKDt7eLHyndOu7QAZXvVxUnRGrsklnHT8YyAzPlVemRhNbUnmNU0GoOp4uDKFIhct9o1bwKx6fGqMrUaTf9P9O6X3GJsE7HM0zrcqLXo6Up3X9vT4c3j1x/JEWRfAlXJoUGhwueSdc= admin@nas' >> /root/.ssh/authorized_keys
