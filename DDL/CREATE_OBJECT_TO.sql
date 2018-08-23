CREATE TABLE  "T_INVENTORY_HISTORY_TO" 
   (	"ID" NUMBER, 
	"T_BTID" VARCHAR2(255), 
	"T_TIME" TIMESTAMP (6) WITH TIME ZONE, 
	"T_PIC" VARCHAR2(255), 
	"T_PIC_NAME" VARCHAR2(255), 
	"T_GROUP1" VARCHAR2(255), 
	"T_FIELD1" VARCHAR2(255), 
	"T_FIELD2" VARCHAR2(255), 
	"T_VALUE" NUMBER, 
	"T_COMMENT" VARCHAR2(255), 
	 CONSTRAINT "T_INVENTORY_HISTORY_TO_PK" PRIMARY KEY ("ID") DISABLE
   )
/
CREATE TABLE  "T_INVENTORY_WORK_TO_TEMP" 
   (	"T_UNIQUE" VARCHAR2(255), 
	"T_FIELD2" VARCHAR2(255), 
	"T_VALUE" NUMBER
   )
/
CREATE TABLE  "T_INVENTORY_HISTORY_TO_BACKUP" 
   (	"ID" NUMBER, 
	"T_BTID" VARCHAR2(255), 
	"T_TIME" TIMESTAMP (6) WITH TIME ZONE, 
	"T_PIC" VARCHAR2(255), 
	"T_PIC_NAME" VARCHAR2(255), 
	"T_GROUP1" VARCHAR2(255), 
	"T_FIELD1" VARCHAR2(255), 
	"T_FIELD2" VARCHAR2(255), 
	"T_VALUE" NUMBER, 
	"T_COMMENT" VARCHAR2(255), 
	 CONSTRAINT "T_INVENTORY_HISTORY_TO_BACKUP_PK" PRIMARY KEY ("ID") DISABLE
   )
/
CREATE TABLE  "T_INITIAL_TO" 
   (	"T_INITIAL_ID" NUMBER, 
	"T_INITIAL_VALUE" VARCHAR2(255), 
	"T_CONTENTS" VARCHAR2(255), 
	 CONSTRAINT "T_INITIAL_TO_PK" PRIMARY KEY ("T_INITIAL_ID")
  USING INDEX  ENABLE
   )
/
CREATE TABLE  "T_INVENTORY_TO_BACKUP" 
   (	"ID" NUMBER, 
	"T_FIELD1" VARCHAR2(255), 
	"T_FIELD2" VARCHAR2(255), 
	"T_GROUP1" VARCHAR2(255), 
	"T_VALUE" NUMBER, 
	"T_JISSEKI" NUMBER, 
	 CONSTRAINT "T_INVENTORY_TO_BACKUP_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )
/
CREATE TABLE  "T_INVENTORY_TO" 
   (	"ID" NUMBER, 
	"T_FIELD1" VARCHAR2(255), 
	"T_FIELD2" VARCHAR2(255), 
	"T_GROUP1" VARCHAR2(255), 
	"T_VALUE" NUMBER, 
	"T_JISSEKI" NUMBER, 
	 CONSTRAINT "T_INVENTORY_TO_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )
/
CREATE TABLE  "T_PIC_MASTER_TO_BACKUP" 
   (	"T_PIC" VARCHAR2(255) NOT NULL ENABLE, 
	"T_PIC_NAME" VARCHAR2(255) NOT NULL ENABLE, 
	"T_PASSWORD" VARCHAR2(255), 
	 CONSTRAINT "T_PIC_MASTER_TO_BACKUP_PK" PRIMARY KEY ("T_PIC")
  USING INDEX  ENABLE
   )
/
CREATE TABLE  "T_INVENTORY_WORK2_TO" 
   (	"T_FIELD1" VARCHAR2(255), 
	"T_FIELD2" VARCHAR2(255)
   )
/
CREATE TABLE  "T_INVENTORY_WORK_TO" 
   (	"T_UNIQUE" VARCHAR2(255), 
	"T_FIELD2" VARCHAR2(255), 
	"T_VALUE" NUMBER
   )
/
CREATE TABLE  "T_INITIAL_TO_BACKUP" 
   (	"T_INITIAL_ID" NUMBER, 
	"T_INITIAL_VALUE" VARCHAR2(255), 
	"T_CONTENTS" VARCHAR2(255), 
	 CONSTRAINT "T_INITIAL_TO_BACKUP_PK" PRIMARY KEY ("T_INITIAL_ID")
  USING INDEX  ENABLE
   )
/
CREATE TABLE  "T_PIC_MASTER_TO" 
   (	"T_PIC" VARCHAR2(255) NOT NULL ENABLE, 
	"T_PIC_NAME" VARCHAR2(255) NOT NULL ENABLE, 
	"T_PASSWORD" VARCHAR2(255), 
	 CONSTRAINT "T_PIC_MASTER_TO_PK" PRIMARY KEY ("T_PIC")
  USING INDEX  ENABLE
   )
/
CREATE UNIQUE INDEX  "T_INITIAL_TO_BACKUP_PK" ON  "T_INITIAL_TO_BACKUP" ("T_INITIAL_ID")
/
CREATE UNIQUE INDEX  "T_INITIAL_TO_PK" ON  "T_INITIAL_TO" ("T_INITIAL_ID")
/
CREATE UNIQUE INDEX  "T_INVENTORY_TO_BACKUP_PK" ON  "T_INVENTORY_TO_BACKUP" ("ID")
/
CREATE UNIQUE INDEX  "T_INVENTORY_TO_PK" ON  "T_INVENTORY_TO" ("ID")
/
CREATE UNIQUE INDEX  "T_PIC_MASTER_TO_BACKUP_PK" ON  "T_PIC_MASTER_TO_BACKUP" ("T_PIC")
/
CREATE UNIQUE INDEX  "T_PIC_MASTER_TO_PK" ON  "T_PIC_MASTER_TO" ("T_PIC")
/
CREATE OR REPLACE EDITIONABLE PACKAGE  "PKG_TO_APP" as 
 
    --���O�C���F�� 
    function FUNCTION_CUSTOM_AUTH ( 
    p_username in varchar2, 
    p_password in varchar2 ) 
    return boolean; 
 
    --�I���f�[�^���Z�b�g
    procedure fnc_ResetInventoryList; 
 
    --�I�����X�g�폜
    procedure fnc_DeleteInventoryList; 
    
    --HT�p�}�X�^�f�[�^�쐬
    procedure fnc_CreateDataForHT
    ( 
        strSQL in varchar2
    ); 
    
    --�}�X�^��荞��
    procedure fnc_ImportInventoryCsv
    ( 
        strFileName in varchar2
    ); 

    --CSV�_�E�����[�h
    function fnc_ExportCSV 
    ( 
        strSQL in varchar2
    ) return BLOB; 
   
end PKG_TO_APP;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY  "PKG_TO_APP" is 
 
    --���O�C���F�� 
	function FUNCTION_CUSTOM_AUTH ( 
	    p_username in varchar2, 
	    p_password in varchar2 ) 
	    return boolean 
 
	as 
 
	    l_user    T_PIC_MASTER_TO.T_PIC%type := upper(p_username); 
	    l_secret  T_PIC_MASTER_TO.T_PASSWORD%type; 
	    l_cred    T_PIC_MASTER_TO.T_PASSWORD%type; 
 
	begin 
	    select 
	    	T_PIC,  
	    	T_PASSWORD  
	    into 
	    	l_user, 
	    	l_secret 
	    from 
	    	T_PIC_MASTER_TO 
	    where 
	    	upper(T_PIC) = p_username; 
 
	    l_cred := utl_raw.cast_to_raw(p_password); 
 
	    if l_secret = l_cred then  
	      return true; 
	    end if; 
 
	    return false; 
 
	exception 
 
	    when NO_DATA_FOUND then 
	      return false; 
 
	end FUNCTION_CUSTOM_AUTH; 


    --�I�����X�g���Z�b�g
    procedure fnc_ResetInventoryList 
    is  
    BEGIN 
 
        --�I�����X�g�폜
        UPDATE 
            T_INVENTORY_TO 
        SET 
            T_JISSEKI = 0; 
 
    end fnc_ResetInventoryList; 


    --�I�����X�g�폜
    procedure fnc_DeleteInventoryList 
    is  
    BEGIN 
 
        --�I�����X�g�폜
        DELETE
        FROM
            T_INVENTORY_TO;
 
    end fnc_DeleteInventoryList; 


    --HT�p�}�X�^�f�[�^�쐬
    procedure fnc_CreateDataForHT
    ( 
        strSQL in varchar2
    )
    IS

        cur SYS_REFCURSOR;
        rec T_INVENTORY_TO%rowtype;

    BEGIN

        -- Delete table T_INVENTORY_WORK_TO;
        DELETE FROM T_INVENTORY_WORK_TO;

        -- Delete table T_INVENTORY_WORK2_TO;
        DELETE FROM T_INVENTORY_WORK2_TO;


        --�f�[�^�̃��R�[�h�Z�b�g���J��
        OPEN cur FOR strSQL;
        LOOP
            FETCH cur into rec;
            EXIT WHEN cur%notfound;
    
            --Insert table T_INVENTORY_WORK_TO
            INSERT INTO 
                T_INVENTORY_WORK_TO 
                ( 
                    T_UNIQUE, 
                    T_FIELD2, 
                    T_VALUE
                ) 
            VALUES
                (
                    rec.T_GROUP1 || '�@' || rec.T_FIELD1,
                    rec.T_FIELD2,
                    rec.T_VALUE
                );
     
            --Insert table T_INVENTORY_WORK2_TO 
            INSERT INTO 
                T_INVENTORY_WORK2_TO 
                ( 
                    T_FIELD1, 
                    T_FIELD2
                ) 
            SELECT 
                rec.T_FIELD1,
                rec.T_FIELD2 
            FROM DUAL
            WHERE NOT EXISTS 
            (
                SELECT 
                    SUB.T_FIELD1 
                FROM 
                    T_INVENTORY_WORK2_TO SUB
                WHERE 
                        SUB.T_FIELD1 =  rec.T_FIELD1
                    AND SUB.T_FIELD2 =  rec.T_FIELD2
            )
            AND ROWNUM = 1; 

        END LOOP;

        --���R�[�h�Z�b�g�����
        CLOSE cur;

    END fnc_CreateDataForHT; 
    
    --�}�X�^��荞��
    procedure fnc_ImportInventoryCsv
    ( 
        strFileName in varchar2
    )
    IS
        v_blob_data       BLOB;
        v_blob_len        NUMBER;
        v_position        NUMBER;
        v_raw_chunk       RAW(10000);
        v_char            CHAR(1);
        c_chunk_len       NUMBER                    := 1;
        v_line            VARCHAR2 (32767)          := NULL;
        v_data_array      wwv_flow_global.vc_arr2;
        v_value           NUMBER                    := 0;
        v_findFlg         NUMBER                    := 0;
        v_cnt             NUMBER                    := 0;
    BEGIN

        --�C���|�[�g��e�[�u�����폜����
        DELETE FROM T_INVENTORY_TO;

        --�ꎞ�t�@�C������t�@�C�����Ō������ăf�[�^���擾����
        SELECT 
            BLOB_CONTENT INTO v_blob_data
        FROM 
            APEX_APPLICATION_TEMP_FILES 
        WHERE 
            Name = strFileName 
            AND ROWNUM = 1;

        v_blob_len := dbms_lob.getlength(v_blob_data);
        v_position := 1;


        --�f�[�^����e�L�X�g�f�[�^�ɕϊ�����
        WHILE ( v_position <= v_blob_len ) LOOP

            v_raw_chunk := dbms_lob.substr(v_blob_data,c_chunk_len,v_position);
            v_char :=  chr(hex_to_decimal(rawtohex(v_raw_chunk)));
            v_line := v_line || v_char;
            v_position := v_position + c_chunk_len;

            --LF�i���s�R�[�h����������j
            IF v_char = CHR(10) THEN
            
                v_cnt         := v_cnt + 1;
                v_findFlg     := 1;
                v_line        := REPLACE (v_line, ',', ':');                    --�J���}(,)��؂��(:)�ɕϊ�
                v_data_array  := wwv_flow_utilities.string_to_table (v_line);   --�u:�v�ŋ�؂��Ĕz��ɓ����
            
                --���o���̗L���𔻒f���Ď�荞��
                IF v_cnt > 1 THEN
                --IF v_cnt > 0 THEN    --���o���Ȃ�
                --IF v_cnt > 1 THEN    --���o������

                    --T_INVENTORY_TO�ɑ��݂��邩�`�F�b�N
                    BEGIN
                        SELECT 
                            NVL(T_VALUE, 0) INTO v_value
                        FROM 
                            T_INVENTORY_TO 
                        WHERE 
                                T_FIELD1 = v_data_array(1)
                            AND T_GROUP1 = v_data_array(4);
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                v_findFlg     := 0;
                    END;

                    --�X�V
                    IF v_findFlg > 0 THEN
                    
                        UPDATE 
                            T_INVENTORY_TO
                        SET 
                            T_VALUE = NVL(v_data_array(3), 0) + v_value
                        WHERE 
                                T_FIELD1 = v_data_array(1)
                            AND T_GROUP1 = v_data_array(4);
                            
                    ELSE
                    
                        --�ǉ�
                        INSERT INTO T_INVENTORY_TO
                              (
                                T_FIELD1, 
                                T_FIELD2, 
                                T_VALUE, 
                                T_GROUP1, 
                                T_JISSEKI
                              )
                          VALUES
                              (
                                TRIM(v_data_array(1)),
                                TRIM(v_data_array(2)),
                                TRIM(v_data_array(3)),
                                TRIM(v_data_array(4)),
                                TRIM(v_data_array(5))
                              );
                              
                    END IF;
                    
                END IF;

                --��������N���A
                v_line    := NULL;
                v_value   := 0;

            END IF;

        END LOOP;


        --���p�����ꎞ�t�@�C�����폜����
        DELETE 
        FROM
            APEX_APPLICATION_FILES 
        WHERE
            Name = strFileName;

        END fnc_ImportInventoryCsv;
        
    --CSV�_�E�����[�h
    function fnc_ExportCSV 
    ( 
        strSQL in varchar2
    ) return BLOB
    AS
        cur SYS_REFCURSOR;
        rec T_INVENTORY_TO%rowtype;
        
        l_blob_result     BLOB;
        l_line            VARCHAR2(32767);

    BEGIN
        --Init BLOB
        DBMS_LOB.createTemporary(l_blob_result, TRUE);
        
        --CREATE HEADER
        l_line           := '';
        l_line           := l_line || '����1' || ',';
        l_line           := l_line || '����2' || ',';
        l_line           := l_line || '�݌ɐ�' || ',';
        l_line           := l_line || '�O���[�v�L�[' || ',';
        l_line           := l_line || '�I����' || ',';
        l_line           := l_line || '����' || '';
        l_line           := l_line || chr(13) || chr(10);
    
        OPEN cur FOR strSQL;
        LOOP
          FETCH cur INTO rec;
          EXIT
          WHEN cur%notfound;
          
          l_line            := l_line || TRIM(NVL(rec.T_FIELD1, '')) || ',';
          l_line            := l_line || TRIM(NVL(rec.T_FIELD2, '')) || ',';
          l_line            := l_line || NVL(rec.T_VALUE, '') || ',';
          l_line            := l_line || TRIM(NVL(rec.T_GROUP1, '')) || ',';
          l_line            := l_line || NVL(rec.T_JISSEKI, '') || ',';
          l_line            := l_line || TO_CHAR(NVL(rec.T_JISSEKI, 0) - NVL(rec.T_VALUE, 0)) || chr(13) || chr(10);

          --Add json to blob
          DBMS_LOB.APPEND(l_blob_result, UTL_RAW.CAST_TO_RAW(l_line));
          l_line            := '';
          
        END LOOP;
        
        --Release Cursor
        CLOSE cur;
        
        return l_blob_result;
          
    END fnc_ExportCSV;
  
end PKG_TO_APP;
/

CREATE OR REPLACE EDITIONABLE PACKAGE  "PKG_TO_DELETE_OLD_DATA" IS 
 
    --�ߋ��f�[�^�폜 
    procedure fnc_DeleteOldData; 
 
    --�ߋ��f�[�^�폜JOB�쐬 
    procedure fnc_JobCreate; 
 
    --�ߋ��f�[�^�폜JOB�폜 
    procedure fnc_JobDelete; 
     
    --�ߋ��f�[�^�폜JOB�L���� 
    procedure fnc_JobEnabled; 
 
    --�ߋ��f�[�^�폜JOB������ 
    procedure fnc_JobDisabled; 
 
END PKG_TO_DELETE_OLD_DATA; 
 
--�o�^�ς݂�JOB�ꗗ�͉��L��SQL�Ŏ擾���� 
--SELECT * FROM USER_SCHEDULER_JOBS;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY  "PKG_TO_DELETE_OLD_DATA" IS 
 
    --�ߋ��f�[�^�폜 
    procedure fnc_DeleteOldData IS 
    BEGIN 
     
        --T_INVENTORY_HISTORY_TO�폜 
        DELETE 
        FROM 
            T_INVENTORY_HISTORY_TO 
        WHERE 
            TO_DATE(SYSDATE, 'yyyy/mm/dd hh24:mi:ss') > TO_DATE(ADD_MONTHS(T_TIME, 12), 'yyyy/mm/dd hh24:mi:ss');  
 
        COMMIT; 
 
    END fnc_DeleteOldData; 
 
 
    --�ߋ��f�[�^�폜JOB�쐬 
    procedure fnc_JobCreate IS 
    BEGIN 
        DBMS_SCHEDULER.CREATE_JOB( 
            job_name => 'JOB_TO_DELETE_OLD_DATA',  
            job_type => 'STORED_PROCEDURE',  
            job_action => 'PKG_DELETE_OLD_DATA.fnc_DeleteOldData',  
            start_date => TO_TIMESTAMP_TZ(CONCAT(TO_CHAR(CURRENT_DATE, 'yyyy/MM/dd'), ' 00:00:00 +09:00'),'yyyy/mm/dd hh24:mi:ss TZH:TZM'),
            repeat_interval => 'FREQ=DAILY;',  
            auto_drop => FALSE, enabled => TRUE); 
    END fnc_JobCreate; 
   
 
    --�ߋ��f�[�^�폜JOB�폜 
    procedure fnc_JobDelete IS 
    BEGIN 
        DBMS_SCHEDULER.DROP_JOB('JOB_TO_DELETE_OLD_DATA'); 
    END fnc_JobDelete; 
 
 
    --�ߋ��f�[�^�폜JOB�L���� 
    procedure fnc_JobEnabled IS 
    BEGIN 
        DBMS_SCHEDULER.ENABLE('JOB_TO_DELETE_OLD_DATA'); 
    END fnc_JobEnabled; 
 
 
    --�ߋ��f�[�^�폜JOB������ 
    procedure fnc_JobDisabled IS 
    BEGIN 
        DBMS_SCHEDULER.DISABLE('JOB_TO_DELETE_OLD_DATA'); 
    END fnc_JobDisabled; 
 
END PKG_TO_DELETE_OLD_DATA;
/

CREATE OR REPLACE EDITIONABLE PACKAGE  "PKG_TO_DRS" as 
 
    --�I���m�� 
    procedure fnc_TCMPCMP 
    ( 
        strPic           IN VARCHAR2, 
        strLocationId    IN VARCHAR2, 
        strHinban        IN VARCHAR2, 
        strSuryo         IN VARCHAR2,
        dtTime           IN TIMESTAMP WITH TIME ZONE DEFAULT systimestamp at time zone 'Asia/Tokyo'
    ); 
 
 
    --�m��(�t�@�C����������) 
    procedure fnc_FCMPCMP 
    ( 
        ja               IN JSON_ARRAY_T 
    ); 
 
end;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY  "PKG_TO_DRS" IS 
 
    --�I���m�� 
    procedure fnc_TCMPCMP 
    ( 
        strPic           VARCHAR2, 
        strLocationId    VARCHAR2, 
        strHinban        VARCHAR2, 
        strSuryo         VARCHAR2,
        dtTime           TIMESTAMP WITH TIME ZONE
    ) 
    AS 
        --�ϐ��錾
        blnFound NUMBER DEFAULT 1;
        OldValue NUMBER; 
        NewValue NUMBER; 
 
        strPicName    T_PIC_MASTER_TO.T_PIC_NAME%TYPE; 
        strField2     T_INVENTORY_TO.T_FIELD2%TYPE; 
        strJisseki    T_INVENTORY_TO.T_JISSEKI%TYPE; 
        
        BEGIN 
 
            --debug
            --DELETE FROM T_DEBUG;

             --debug
            --INSERT INTO T_DEBUG (T_MESSAGE) VALUES('fnc_TCMPCMP');
            --commit;
                
            --�� �S���Җ����擾���Ă��� -------------------------------------------------------------------- 
            BEGIN 
 
                SELECT 
                    T_PIC_NAME 
                    INTO strPicName 
                FROM 
                    T_PIC_MASTER_ZK 
                WHERE 
                    T_PIC = strPic 
                    OR upper(T_PIC) = strPic; 
                    --�蓮���͂���̓��͂�z�肵�āA�啶���ł��������Ă��� 
 
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    strPicName := ''; 
            END; 
            --�� �S���Җ����擾���Ă��� -------------------------------------------------------------------- 

 
            --�� �݌ɂ��X�V���� -------------------------------------------------------------------- 
            BEGIN 
 
            commit;
                --���݌ɐ����擾���� 
                BEGIN 
                 
                    SELECT 
                        T_JISSEKI,
                        T_FIELD2
                        INTO 
                        strJisseki,
                        strField2
                    FROM 
                        T_INVENTORY_TO 
                    WHERE 
                        T_GROUP1 = strLocationId 
                        and T_FIELD1 = strHinban 
                        and rownum = 1; 
 
                    EXCEPTION 
                        WHEN NO_DATA_FOUND THEN 
                            blnFound := 0;    --�Y���Ȃ�
                            strJisseki := NULL;
                            strField2 := NULL;
                END; 
                IF blnFound = 1 THEN 
                    OldValue := NVL(strJisseki, 0); 
                ELSE 
                    OldValue := 0; 
                END IF;
                 
                --T_INVENTORY_TO�e�[�u���X�V 
                IF blnFound = 1 THEN 
 
                    --�݌ɐ��X�V 
                    UPDATE 
                        T_INVENTORY_TO 
                    SET 
                        T_JISSEKI = OldValue + TO_NUMBER(strSuryo)
                    WHERE 
                        T_GROUP1 = strLocationId 
                        and T_FIELD1 = strHinban 
                        and rownum = 1; 

                ELSE 

                    --���R�[�h�ǉ� 
                    INSERT INTO 
                        T_INVENTORY_TO 
                        ( 
                            T_GROUP1, 
                            T_FIELD1, 
                            T_VALUE, 
                            T_JISSEKI 
                        ) 
                        VALUES
                        (
                            strLocationId, 
                            strHinban, 
                            0, 
                            strSuryo 
                        );

                END IF; 
                 
            END; 
            
            INSERT INTO 
                T_INVENTORY_HISTORY_TO 
                ( 
                    T_TIME, 
                    T_PIC, 
                    T_PIC_NAME, 
                    T_GROUP1, 
                    T_FIELD1, 
                    T_FIELD2, 
                    T_VALUE
                ) 
            VALUES
                (
                    dtTime, 
                    strPic, 
                    strPicName, 
                    strLocationId, 
                    strHinban, 
                    strField2, 
                    strSuryo 
                );

        END fnc_TCMPCMP; 
         
         
    --�m��(�t�@�C����������) 
    procedure fnc_FCMPCMP 
    ( 
        ja          JSON_ARRAY_T 
    ) 
    AS 
        --�ϐ��錾 
        je JSON_ELEMENT_T; 
        jo JSON_OBJECT_T; 
 
        strRecord VARCHAR2(4000); 
        strTime VARCHAR2(50); 
        strBTID VARCHAR2(10); 
        strPic VARCHAR2(255); 
        strLocationId VARCHAR2(255); 
        strField1 VARCHAR2(4000); 
        strSuryo VARCHAR2(255); 
 
    BEGIN 
        --debug
        --DELETE FROM T_DEBUG;
        --commit;

        --�z�񕪂̏��������� 
        for i in 0..ja.get_size - 1 
        loop 
 
            --JSON�̔z�񂩂�P�s�����o�� 
            je := ja.get(i); 
            if (je.is_object) then 
 
                --JSON�I�u�W�F�N�g�ɕϊ� 
                jo := treat(je as json_object_t); 
 
                --�I�u�W�F�N�g���擾 
                strRecord := jo.get('record').to_string; 
                strRecord := REPLACE(strRecord, '"', '');    --�擪�Ɩ����̃_�u���N�H�[�e�[�V�����΍� 
                strTime := strtoken(strRecord, ',', 1); 
                strBTID := strtoken(strRecord, ',', 2); 
                strPic := strtoken(strRecord, ',', 3); 
                strLocationId := strtoken(strRecord, ',', 4); 
                strField1 := strtoken(strRecord, ',', 5); 
                strSuryo := strtoken(strRecord, ',', 6); 
                
                --��������
                PKG_TO_DRS.fnc_TCMPCMP(strPic, strLocationId, strField1, strSuryo, TO_TIMESTAMP_TZ(CONCAT(strTime, ' +09:00'), 'YYYY-MM-DD HH24:MI:SS TZH:TZM')); 

            end if; 
 
        end loop; 

    END fnc_FCMPCMP;  
 
END PKG_TO_DRS;
/

CREATE OR REPLACE EDITIONABLE PACKAGE  "PKG_TO_RESET_DEMO_DATA" IS 
 
    --�f���f�[�^���Z�b�g
    procedure fnc_ResetDemoData; 
 
    --�f���f�[�^���Z�b�gJOB�쐬 
    procedure fnc_JobCreate; 
 
    --�f���f�[�^���Z�b�gJOB�폜 
    procedure fnc_JobDelete; 
     
    --�f���f�[�^���Z�b�gJOB�L���� 
    procedure fnc_JobEnabled; 
 
    --�f���f�[�^���Z�b�gJOB������ 
    procedure fnc_JobDisabled; 
 
END PKG_TO_RESET_DEMO_DATA;
 
--�o�^�ς݂�JOB�ꗗ�͉��L��SQL�Ŏ擾���� 
--SELECT * FROM USER_SCHEDULER_JOBS;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY  "PKG_TO_RESET_DEMO_DATA" IS 
 
    --�f���f�[�^���Z�b�g 
    procedure fnc_ResetDemoData
    IS
   
        --�ϐ��錾 
        RECORDCOUNT   NUMBER; 
        dtLatestDate   T_INVENTORY_HISTORY_TO.T_TIME%TYPE; 
        DateCount   NUMBER; 
    
    BEGIN
    
        --debug
        DELETE FROM T_DEBUG;

        --T_***_BACKUP�e�[�u�����f�[�^��߂�
        DELETE from T_INITIAL_TO;
        INSERT INTO T_INITIAL_TO SELECT * FROM T_INITIAL_TO_BACKUP;

        DELETE from T_INVENTORY_HISTORY_TO;
        INSERT INTO T_INVENTORY_HISTORY_TO SELECT * FROM T_INVENTORY_HISTORY_TO_BACKUP;

        DELETE from T_PIC_MASTER_TO;
        INSERT INTO T_PIC_MASTER_TO SELECT * FROM T_PIC_MASTER_TO_BACKUP;

        DELETE from T_INVENTORY_TO;
        INSERT INTO T_INVENTORY_TO SELECT * FROM T_INVENTORY_TO_BACKUP;

        --HT�ւ̃}�X�^�p���[�N�e�[�u�����폜
        DELETE FROM T_INVENTORY_WORK_TO;
        DELETE FROM T_INVENTORY_WORK2_TO;

        --�� T_INVENTORY_HISTORY_TO�̓��t��V�������� -------------------------------------------------------------------- 

        -- T_INVENTORY_HISTORY_TO�̃��R�[�h�����邩�ǂ���
        BEGIN
            select
                COUNT(*) 
                INTO RECORDCOUNT
            FROM
                T_INVENTORY_HISTORY_TO;
        END;
        
        --�����f�[�^���Ȃ���Δ�����
        IF RECORDCOUNT = 0 then
            return;
        END IF;
        
        --debug
        --INSERT INTO T_DEBUG (T_MESSAGE) VALUES(TO_CHAR(RECORDCOUNT));

        --�ł��V�������t���擾
        BEGIN
            SELECT
                MAX(T_TIME)
                INTO dtLatestDate
            FROM
                T_INVENTORY_HISTORY_TO;
        END;
        --debug
        --INSERT INTO T_DEBUG (T_MESSAGE) VALUES(TO_CHAR(dtLatestDate));

        --�{���Ƃ̍������擾
        BEGIN
            SELECT
                SYSDATE - CAST(dtLatestDate AS DATE)
                INTO DateCount
            FROM
                DUAL;
        END;
        DateCount := TRUNC(DateCount);
        --debug
        --INSERT INTO T_DEBUG (T_MESSAGE) VALUES(TO_CHAR(DateCount));
        
        --���t���X�V
        UPDATE
            T_INVENTORY_HISTORY_TO
        SET
            T_TIME = FROM_TZ (cast(T_TIME + DateCount as timestamp), 'ASIA/TOKYO');
        
        --�ł��V�������t���擾
        BEGIN
            SELECT
                MAX(T_TIME)
                INTO dtLatestDate
            FROM
                T_INVENTORY_HISTORY_TO;
        END;
        --debug
        --INSERT INTO T_DEBUG (T_MESSAGE) VALUES(TO_CHAR(dtLatestDate));

        --�� T_INVENTORY_HISTORY_TO�̓��t��V�������� -------------------------------------------------------------------- 

    END fnc_ResetDemoData; 
 
 
    --�f���f�[�^���Z�b�gJOB�쐬 
    procedure fnc_JobCreate IS 
    BEGIN 
        DBMS_SCHEDULER.CREATE_JOB( 
        job_name => 'JOB_TO_RESET_DEMO_DATA',  
        job_type => 'STORED_PROCEDURE',  
        job_action => 'PKG_RESET_DEMO_DATA.fnc_ResetDemoData',  
        start_date => TO_TIMESTAMP_TZ(CONCAT(TO_CHAR(CURRENT_DATE, 'yyyy/MM/dd'), ' 00:00:00 +09:00'),'yyyy/mm/dd hh24:mi:ss TZH:TZM'),
        repeat_interval => 'FREQ=DAILY;BYHOUR=0;',  
        auto_drop => FALSE, enabled => TRUE); 
    END fnc_JobCreate; 
   
 
    --�f���f�[�^���Z�b�gJOB�폜 
    procedure fnc_JobDelete IS 
    BEGIN 
        DBMS_SCHEDULER.DROP_JOB('JOB_TO_RESET_DEMO_DATA'); 
    END fnc_JobDelete; 
 
 
    --�f���f�[�^���Z�b�gJOB�L���� 
    procedure fnc_JobEnabled IS 
    BEGIN 
        DBMS_SCHEDULER.ENABLE('JOB_TO_RESET_DEMO_DATA'); 
    END fnc_JobEnabled; 
 
 
    --�f���f�[�^���Z�b�gJOB������ 
    procedure fnc_JobDisabled IS 
    BEGIN 
        DBMS_SCHEDULER.DISABLE('JOB_TO_RESET_DEMO_DATA'); 
    END fnc_JobDisabled; 
 
END PKG_TO_RESET_DEMO_DATA; 
/

 CREATE SEQUENCE   "T_INVENTORY_HISTORY_TO_BACKUP_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 81 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL
/
 CREATE SEQUENCE   "T_INVENTORY_TO_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 2921 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL
/
 CREATE SEQUENCE   "T_INVENTORY_HISTORY_TO_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 121 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL
/
 CREATE SEQUENCE   "T_INVENTORY_TO_BACKUP_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 161 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL
/
CREATE OR REPLACE EDITIONABLE TRIGGER  "bi_T_INVENTORY_HISTORY_TO" 
  before insert on "T_INVENTORY_HISTORY_TO"               
  for each row  
begin   
  if :new."ID" is null then 
    select "T_INVENTORY_HISTORY_TO_SEQ".nextval into :new."ID" from sys.dual; 
  end if; 
end;

/
ALTER TRIGGER  "bi_T_INVENTORY_HISTORY_TO" ENABLE
/
CREATE OR REPLACE EDITIONABLE TRIGGER  "bi_T_INVENTORY_HISTORY_TO_BACKUP" 
  before insert on "T_INVENTORY_HISTORY_TO_BACKUP"               
  for each row  
begin   
  if :new."ID" is null then 
    select "T_INVENTORY_HISTORY_TO_BACKUP_SEQ".nextval into :new."ID" from sys.dual; 
  end if; 
end;

/
ALTER TRIGGER  "bi_T_INVENTORY_HISTORY_TO_BACKUP" ENABLE
/
CREATE OR REPLACE EDITIONABLE TRIGGER  "bi_T_INVENTORY_TO" 
  before insert on "T_INVENTORY_TO"               
  for each row  
begin   
  if :new."ID" is null then 
    select "T_INVENTORY_TO_SEQ".nextval into :new."ID" from sys.dual; 
  end if; 
end;

/
ALTER TRIGGER  "bi_T_INVENTORY_TO" ENABLE
/
CREATE OR REPLACE EDITIONABLE TRIGGER  "bi_T_INVENTORY_TO_BACKUP" 
  before insert on "T_INVENTORY_TO_BACKUP"               
  for each row  
begin   
  if :new."ID" is null then 
    select "T_INVENTORY_TO_BACKUP_SEQ".nextval into :new."ID" from sys.dual; 
  end if; 
end;

/
ALTER TRIGGER  "bi_T_INVENTORY_TO_BACKUP" ENABLE
/