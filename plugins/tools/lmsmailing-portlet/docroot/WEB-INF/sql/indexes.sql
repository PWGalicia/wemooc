create index IX_BE6FFF5F on lmsmail_AuditSendMails (uuid_);
create unique index IX_7FE5502B on lmsmail_AuditSendMails (uuid_, groupId);

create index IX_CA7513DB on lmsmail_MailTemplate (companyId);
create index IX_3E56D51D on lmsmail_MailTemplate (groupId);
create index IX_AC690AE7 on lmsmail_MailTemplate (uuid_);
create unique index IX_28ECBDA3 on lmsmail_MailTemplate (uuid_, groupId);