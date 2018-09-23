import telebot, db_postgres, strformat, asyncdispatch, os, strutils

var JOB_ID: int
try:
  JOB_ID = parseInt(paramStr(1))
except:
  quit(1)



const
  API_KEY = slurp("secret.key")
  CHAT_ID = parseInt(slurp("chat.id"))
  DB_PASSWORD =  slurp("db.passwd")


let
  db = open("127.0.0.1", "bareos", DB_PASSWORD, "bareos")
  row = db.getRow(sql"""
SELECT
 j.jobid,
 j.name,
 j.level,
 j.jobstatus,
 j.starttime,
 j.endtime,
 c.name AS client,
 p.name AS pool,
 s.jobstatuslong AS status
FROM Job j
INNER JOIN Pool p ON p.poolid = j.poolid
INNER JOIN Client c ON c.clientid = j.clientid
INNER JOIN Status as s on s.jobstatus = j.jobstatus
WHERE j.jobid=?""", JOB_ID)
db.close()

var
  message: string
  status: string
  level: string

if row[3] == "T":
  message = &"*[{row[0]}] BACKUP OK*\n"
else:
  message = &"*[{row[0]}] BACKUP ERROR*\n"

if row[3] == "T":
  status = "OK"
else:
  status = "ERROR"


if row[2] == "F":
  level = "Full"
elif row[2] == "I":
  level = "Incremental"
else:
  level = "Differential"

message.add(&"Job Name: {row[1]}\n")
message.add(&"Client: {row[6]}\n")
#message.add(&"Job Status: {status}\n")
message.add(&"Level: {level}\n")
message.add(&"Start Time: {row[4]}\n")
message.add(&"End time: {row[5]}\n")
message.add(&"Pool: {row[7]}\n")
message.add(&"Status: {row[8]}\n")


let b = newTeleBot(API_KEY)
var m = newMessage(CHAT_ID, message)
m.disableNotification = false
m.parseMode = "markdown"

discard waitFor b.send(m)
