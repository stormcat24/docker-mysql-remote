# docker-mysql-remote

![image](docker-mysql-remote.png)

### Usage

##### docker-compose

```Ruby
mysql:
  image: stormcat24/mysql-remote:latest
  ports:
    - 3306:3306
  environment:
    MYSQL_ROOT_PASSWORD: ""
    MYSQL_DATABASE: test # anything ok
    MYSQL_USER: youruser
    MYSQL_PASSWORD: yourpassword
    MYSQL_ALLOW_EMPTY_PASSWORD: yes
    IMPORT_SOURCES: "your_db_host1,3306,username,password,database1|your_db_host2,3306,username,password,database2"
```
