# backup_information
Collect information from backup FILE or DIRECTORY
## Support
- cPanel backup
- Directadmin backup
## How to use?
```
sh main.sh [backup file or directory]
```
## Example:
### cPanel
```
[root@local backups]# sh main.sh cpmove-thanh
{
    "user": {
        "name": "thanh",
        "password": "$6$xybSIVXdMHK2tdZP$vLBIiJuXiDr/Shb1DTja7ifcCvh.TSPUEXpfV4qyqBhL0fKRek6n3gTP4902hRrcjUNfcZ4XVXyFXLIDu191r1",
        "shell": "/bin/bash"
    },
    "domain": {
        "main": "thanh.com",
         "addon": ["thanh-addon1.net", "thanh-addon2.net"],
        "alias": {
            "thanh.com": "[thanh-alias1.com, thanh-alias2.com, thanh-alias3.com]",
            "thanh-addon2.net": "thanh-addon2-alias1.info"
        },
        "sub": {
            "thanh-addon1.net": "sub1",
            "thanh.com": "[sub1, sub2, sub3]",
            "thanh-addon2.net": ""
        }
    },
    "database": {
        "all": ["thanh_db1", "thanh_db2"],
        "privilege": {
            "thanh_db1": {
                "thanh_user1": "ALTER, CREATE TEMPORARY TABLES, EXECUTE, SHOW VIEW",
                "thanh_user2": "ALL PRIVILEGES"
            },
            "thanh_db2": {
                "thanh_user1": "ALL PRIVILEGES"
            }
        }
    }
}
```
### DirectAdmin
```
[root@local backups]# sh main.sh backup-Aug-26-2020-1.tar.gz 
{
    "user": {
        "name": "thanh",
        "password": "$1$58Iq0x31$hqR99sYYLw2gcT5GjgZkM.",
        "shell": "/bin/bash"
    },
    "domain": {
        "main": "thanh.com",
        "addon": ["thanh-addon1.net", "thanh-addon2.net"],
        "alias": {
            "thanh.com": "[thanh-alias1.com, thanh-alias2.com, thanh-alias3.com]",
            "thanh-addon2.net": "thanh-addon2-alias1.info"
        },
        "sub": {
            "thanh-addon1.net": "sub1",
            "thanh.com": "[sub1, sub2, sub3]",
            "thanh-addon2.net": ""
        }
    },
    "database": {
        "all": ["thanh_db1", "thanh_db2"],
        "privilege": {
            "thanh_db1": {
                "thanh_user1": "ALTER, ALTER ROUTINE, CREATE TMP TABLE, CREATE VIEW, DELETE, DROP, EVENT, EXECUTE, INDEX, INSERT, REFERENCES, SELECT, SHOW VIEW, TRIGGER, UPDATE"
            },
            "thanh_db2": {
                "thanh_user1": "ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TMP TABLE, CREATE VIEW, DELETE, DROP, EVENT, EXECUTE, INDEX, INSERT, LOCK TABLES, REFERENCES, SELECT, SHOW VIEW, TRIGGER, UPDATE",
                "thanh_user2": "ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TMP TABLE, CREATE VIEW, DELETE, DROP, EVENT, EXECUTE, GRANT, INDEX, INSERT, REFERENCES, SELECT, SHOW VIEW, TRIGGER, UPDATE"
            }
        }
    }
}
```
