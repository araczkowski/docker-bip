docker-bip
============================

Oracle BI Publisher 11.1.1.7.1 (Trial Edition) with samples

### Building

    docker build -t bip .

### Installation

    docker pull araczkowski/bip

#### Run with 1527, 7001 ports opened:

    docker run -d --name bip -p 1527:1527 -p 7001:7001 araczkowski/bip    


###### login to the BIP

    url: http://localhost:47001/xmlpserver
    user: admin
    pass: admin123
