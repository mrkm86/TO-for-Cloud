--TABLE-------------------------------------------------------------------------
CREATE TABLE  "T_INITIAL_TO" 
   (	"T_INITIAL_ID" NUMBER, 
	"T_INITIAL_VALUE" VARCHAR2(255), 
	"T_CONTENTS" VARCHAR2(255), 
	 CONSTRAINT "T_INITIAL_TO_PK" PRIMARY KEY ("T_INITIAL_ID")
  USING INDEX  ENABLE
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
CREATE TABLE  "T_INVENTORY_WORK_TO_TEMP" 
   (	"T_UNIQUE" VARCHAR2(255), 
	"T_FIELD2" VARCHAR2(255), 
	"T_VALUE" NUMBER
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
CREATE TABLE  "T_PIC_MASTER_TO_BACKUP" 
   (	"T_PIC" VARCHAR2(255) NOT NULL ENABLE, 
	"T_PIC_NAME" VARCHAR2(255) NOT NULL ENABLE, 
	"T_PASSWORD" VARCHAR2(255), 
	 CONSTRAINT "T_PIC_MASTER_TO_BACKUP_PK" PRIMARY KEY ("T_PIC")
  USING INDEX  ENABLE
   )
/

--SEQUENCE  -------------------------------------------------------------------------
 CREATE SEQUENCE   "T_INVENTORY_HISTORY_TO_BACKUP_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 81 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL
/
 CREATE SEQUENCE   "T_INVENTORY_HISTORY_TO_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 141 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL
/
 CREATE SEQUENCE   "T_INVENTORY_TO_BACKUP_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 161 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL
/
 CREATE SEQUENCE   "T_INVENTORY_TO_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 6041 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL
/
--PACKAGE  -------------------------------------------------------------------------
----HEADER
create or replace PACKAGE  "PKG_TO_APP" as 
 
    --ログイン認証 
    function FUNCTION_CUSTOM_AUTH ( 
    p_username in varchar2, 
    p_password in varchar2 ) 
    return boolean; 
 
    --棚卸データリセット
    procedure fnc_ResetInventoryList; 
 
    --棚卸リスト削除
    procedure fnc_DeleteInventoryList; 
    
    --HT用マスタデータ作成
    procedure fnc_CreateDataForHT
    ( 
        strSQL in varchar2
    ); 
    
    --マスタ取り込み
    procedure fnc_ImportInventoryCsv
    ( 
        strFileName in varchar2
    ); 

    --CSVダウンロード
    function fnc_ExportCSV 
    ( 
        strSQL in varchar2
    ) return BLOB; 
    
end PKG_TO_APP;
/
----BODY
create or replace PACKAGE BODY  "PKG_TO_APP" is 
 
    --ログイン認証 
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


    --棚卸リストリセット
    procedure fnc_ResetInventoryList 
    is  
    BEGIN 
 
        --棚卸リスト削除
        UPDATE 
            T_INVENTORY_TO 
        SET 
            T_JISSEKI = 0; 
 
    end fnc_ResetInventoryList; 


    --棚卸リスト削除
    procedure fnc_DeleteInventoryList 
    is  
    BEGIN 
 
        --棚卸リスト削除
        DELETE
        FROM
            T_INVENTORY_TO;
 
    end fnc_DeleteInventoryList; 


    --HT用マスタデータ作成
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


        --データのレコードセットを開く
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
                    rec.T_GROUP1 || '　' || rec.T_FIELD1,
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

        --レコードセットを閉じる
        CLOSE cur;

    END fnc_CreateDataForHT; 


    --マスタ取り込み
    procedure fnc_ImportInventoryCsv
    ( 
        strFileName in varchar2
    )
    IS
    
        v_blob_data       BLOB;                                --アップロードされたファイルBLOB
        v_blob_len        NUMBER;                              --アップロードされたファイルのバイト数
        l_blob_result 	  BLOB;                                --読み込み済データ
		amount 			  NUMBER := 32767;                     --１度に読取可能なバイト数
		buf    			  VARCHAR2(32767);                     --読取データ（文字列）
		arr 			  APEX_APPLICATION_GLOBAL.VC_ARR2;     --読取データ（行ごとに分割）
        v_line            VARCHAR2 (32767)          := NULL;   --１行のデータ
		offset 			  NUMBER := 1;                         --カーソル位置（ファイル先頭からの位置）
        v_data_array      wwv_flow_global.vc_arr2;             --１行のデータ（フィールド区切り）
        v_value           NUMBER                    := 0;      --在庫数
        v_findFlg         NUMBER                    := 0;      --テーブル有無判定フラグ
       
    BEGIN
        --debug
        --DELETE FROM T_DEBUG;

        --実績クリア
        UPDATE
            T_INVENTORY_TO
        SET
            T_JISSEKI = null;

        --一時ファイルからファイル名で検索してデータを取得する
        SELECT 
            BLOB_CONTENT INTO v_blob_data
        FROM 
            APEX_APPLICATION_TEMP_FILES 
        WHERE 
            Name = strFileName 
            AND ROWNUM = 1;
	    
        --BLOBデータ長を取得する
		v_blob_len := dbms_lob.getlength(v_blob_data); 

        --読み込み済データの格納変数にデータ長分のメモリ確保
        DBMS_LOB.createTemporary(l_blob_result, TRUE);

        --LF(CHR(10))で区切って、配列に入れる
        arr := APEX_UTIL.string_to_table(buf, CHR(10));

        --カーソル(offset)がファイル長よりも少ないうちは処理を続ける
		WHILE offset < v_blob_len LOOP
        
            --buf(varchar2)にamountの長さ（32767）だけ読み込む
            buf := UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(v_blob_data,amount,offset));
            --読み込んだ分だけカーソルを移動しておく
            offset := offset + amount;

            --LF(CHR(10))で区切って、配列に入れる
            arr := APEX_UTIL.string_to_table(buf, CHR(10));

            --配列の数だけ回す
            FOR i IN 1..arr.COUNT LOOP
            
                --読み込めた範囲内で、配列ごとに処理をする
                IF i < arr.COUNT THEN

                    --改行をなくす
                    v_line := arr(i);
                    v_line := REPLACE (v_line, CHR(10), '');
                    v_line := REPLACE (v_line, CHR(13), '');

                    --空白行でなければ処理をする
                    IF v_line IS NOT NULL THEN

                        --debug
                        --INSERT INTO T_DEBUG (T_MESSAGE) VALUES( v_line );
                        --commit;

                        --カンマ区切りで分割
                        v_data_array  := wwv_flow_utilities.string_to_table (v_line, ',');

                        --フラグを初期化
                        v_findFlg := 1;

                        --T_INVENTORY_TOに存在するかチェック
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

                        --テーブル更新
                        IF v_findFlg > 0 THEN

                            --更新
                            UPDATE 
                                T_INVENTORY_TO
                            SET 
                                T_VALUE = NVL(v_data_array(3), 0) + v_value
                            WHERE 
                                    T_FIELD1 = v_data_array(1)
                                AND T_GROUP1 = v_data_array(4);

                        ELSE

                            --追加
                            INSERT INTO T_INVENTORY_TO
                                  (
                                    T_FIELD1, 
                                    T_FIELD2, 
                                    T_VALUE, 
                                    T_GROUP1
                                  )
                              VALUES
                                  (
                                    TRIM(v_data_array(1)),
                                    TRIM(v_data_array(2)),
                                    TRIM(v_data_array(3)),
                                    TRIM(v_data_array(4))
                                  );

                        END IF;

                        --処理の最後に、読み込み済変数に改行(CrLf)を付け直しておく
                        DBMS_LOB.APPEND(l_blob_result, UTL_RAW.CAST_TO_RAW(v_line || CHR(13) || chr(10)));

                    END IF;
                 
                --最終行の扱いに気を付ける（１度に32762バイトしか読み込めないので、最後の行は中途半端になっている可能性がある。処理済みのデータの終了位置から読み込みなおす。）
                ELSE
                
                    --読み込み済変数のデータ長を取得
                    offset := length(l_blob_result);

                END IF;
                
            End Loop;

        End Loop;


        --利用した一時ファイルを削除する
        DELETE
        FROM
            APEX_APPLICATION_FILES 
        WHERE
            Name = strFileName;
		
	END fnc_ImportInventoryCsv;


    --CSVダウンロード
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
        l_line           := l_line || '項目1' || ',';
        l_line           := l_line || '項目2' || ',';
        l_line           := l_line || '在庫数' || ',';
        l_line           := l_line || 'グループキー' || ',';
        l_line           := l_line || '棚卸数' || ',';
        l_line           := l_line || '差異' || '';
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
----HEADER
create or replace PACKAGE  "PKG_TO_DELETE_OLD_DATA" IS 
 
    --過去データ削除 
    procedure fnc_DeleteOldData; 
 
    --過去データ削除JOB作成 
    procedure fnc_JobCreate; 
 
    --過去データ削除JOB削除 
    procedure fnc_JobDelete; 
     
    --過去データ削除JOB有効化 
    procedure fnc_JobEnabled; 
 
    --過去データ削除JOB無効化 
    procedure fnc_JobDisabled; 
 
END PKG_TO_DELETE_OLD_DATA; 
 
--登録済みのJOB一覧は下記のSQLで取得する 
--SELECT * FROM USER_SCHEDULER_JOBS;
/
----BODY
create or replace PACKAGE BODY  "PKG_TO_DELETE_OLD_DATA" IS 
 
    --過去データ削除 
    procedure fnc_DeleteOldData IS 
    BEGIN 
     
        --T_INVENTORY_HISTORY_TO削除 
        DELETE 
        FROM 
            T_INVENTORY_HISTORY_TO 
        WHERE 
            TO_DATE(SYSDATE, 'yyyy/mm/dd hh24:mi:ss') > TO_DATE(ADD_MONTHS(T_TIME, 12), 'yyyy/mm/dd hh24:mi:ss');  
 
        COMMIT; 
 
    END fnc_DeleteOldData; 
 
 
    --過去データ削除JOB作成 
    procedure fnc_JobCreate IS 
    BEGIN 
        DBMS_SCHEDULER.CREATE_JOB( 
            job_name => 'JOB_TO_DELETE_OLD_DATA',  
            job_type => 'STORED_PROCEDURE',  
            job_action => 'PKG_TO_DELETE_OLD_DATA.fnc_DeleteOldData',  
            start_date => TO_TIMESTAMP_TZ(CONCAT(TO_CHAR(CURRENT_DATE, 'yyyy/MM/dd'), ' 00:00:00 +09:00'),'yyyy/mm/dd hh24:mi:ss TZH:TZM'),
            repeat_interval => 'FREQ=DAILY;',  
            auto_drop => FALSE, enabled => TRUE); 
    END fnc_JobCreate; 
   
 
    --過去データ削除JOB削除 
    procedure fnc_JobDelete IS 
    BEGIN 
        DBMS_SCHEDULER.DROP_JOB('JOB_TO_DELETE_OLD_DATA'); 
    END fnc_JobDelete; 
 
 
    --過去データ削除JOB有効化 
    procedure fnc_JobEnabled IS 
    BEGIN 
        DBMS_SCHEDULER.ENABLE('JOB_TO_DELETE_OLD_DATA'); 
    END fnc_JobEnabled; 
 
 
    --過去データ削除JOB無効化 
    procedure fnc_JobDisabled IS 
    BEGIN 
        DBMS_SCHEDULER.DISABLE('JOB_TO_DELETE_OLD_DATA'); 
    END fnc_JobDisabled; 
 
END PKG_TO_DELETE_OLD_DATA;
/
----HEADER
create or replace PACKAGE  "PKG_TO_DRS" as 
 
    --棚卸確定 
    procedure fnc_TCMPCMP 
    ( 
        strPic           IN VARCHAR2, 
        strLocationId    IN VARCHAR2, 
        strHinban        IN VARCHAR2, 
        strSuryo         IN VARCHAR2,
        dtTime           IN TIMESTAMP WITH TIME ZONE DEFAULT systimestamp at time zone 'Asia/Tokyo'
    ); 
 
 
    --確定(ファイル書き込み) 
    procedure fnc_FCMPCMP 
    ( 
        ja               IN JSON_ARRAY_T 
    ); 
 
end;
/
----BODY
create or replace PACKAGE BODY  "PKG_TO_DRS" IS 
 
    --棚卸確定 
    procedure fnc_TCMPCMP 
    ( 
        strPic           VARCHAR2, 
        strLocationId    VARCHAR2, 
        strHinban        VARCHAR2, 
        strSuryo         VARCHAR2,
        dtTime           TIMESTAMP WITH TIME ZONE
    ) 
    AS 
        --変数宣言
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
                
            --↓ 担当者名を取得しておく -------------------------------------------------------------------- 
            BEGIN 
 
                SELECT 
                    T_PIC_NAME 
                    INTO strPicName 
                FROM 
                    T_PIC_MASTER_TO 
                WHERE 
                    T_PIC = strPic 
                    OR upper(T_PIC) = strPic; 
                    --手動入力からの入力を想定して、大文字でも検索しておく 
 
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    strPicName := ''; 
            END; 
            --↑ 担当者名を取得しておく -------------------------------------------------------------------- 

 
            --↓ 在庫を更新する -------------------------------------------------------------------- 
            BEGIN 
 
            commit;
                --現在庫数を取得する 
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
                            blnFound := 0;    --該当なし
                            strJisseki := NULL;
                            strField2 := NULL;
                END; 
                IF blnFound = 1 THEN 
                    OldValue := NVL(strJisseki, 0); 
                ELSE 
                    OldValue := 0; 
                END IF;
                 
                --T_INVENTORY_TOテーブル更新 
                IF blnFound = 1 THEN 
 
                    --在庫数更新 
                    UPDATE 
                        T_INVENTORY_TO 
                    SET 
                        T_JISSEKI = OldValue + TO_NUMBER(strSuryo)
                    WHERE 
                        T_GROUP1 = strLocationId 
                        and T_FIELD1 = strHinban 
                        and rownum = 1; 

                ELSE 

                    --レコード追加 
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
         
         
    --確定(ファイル書き込み) 
    procedure fnc_FCMPCMP 
    ( 
        ja          JSON_ARRAY_T 
    ) 
    AS 
        --変数宣言 
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

        --配列分の処理をする 
        for i in 0..ja.get_size - 1 
        loop 
 
            --JSONの配列から１行ずつ取り出す 
            je := ja.get(i); 
            if (je.is_object) then 
 
                --JSONオブジェクトに変換 
                jo := treat(je as json_object_t); 
 
                --オブジェクトを取得 
                strRecord := jo.get('record').to_string; 
                strRecord := REPLACE(strRecord, '"', '');    --先頭と末尾のダブルクォーテーション対策 
                strTime := strtoken(strRecord, ',', 1); 
                strBTID := strtoken(strRecord, ',', 2); 
                strPic := strtoken(strRecord, ',', 3); 
                strLocationId := strtoken(strRecord, ',', 4); 
                strField1 := strtoken(strRecord, ',', 5); 
                strSuryo := strtoken(strRecord, ',', 6); 
                
                --書き込み
                PKG_TO_DRS.fnc_TCMPCMP(strPic, strLocationId, strField1, strSuryo, TO_TIMESTAMP_TZ(CONCAT(strTime, ' +09:00'), 'YYYY-MM-DD HH24:MI:SS TZH:TZM')); 

            end if; 
 
        end loop; 

    END fnc_FCMPCMP;  
 
END PKG_TO_DRS;
/
----HEADER
create or replace PACKAGE  "PKG_TO_RESET_DEMO_DATA" IS 
 
    --デモデータリセット
    procedure fnc_ResetDemoData; 
 
    --デモデータリセットJOB作成 
    procedure fnc_JobCreate; 
 
    --デモデータリセットJOB削除 
    procedure fnc_JobDelete; 
     
    --デモデータリセットJOB有効化 
    procedure fnc_JobEnabled; 
 
    --デモデータリセットJOB無効化 
    procedure fnc_JobDisabled; 
 
END PKG_TO_RESET_DEMO_DATA;
 
--登録済みのJOB一覧は下記のSQLで取得する 
--SELECT * FROM USER_SCHEDULER_JOBS;
/
----BODY
create or replace PACKAGE BODY  "PKG_TO_RESET_DEMO_DATA" IS 
 
    --デモデータリセット 
    procedure fnc_ResetDemoData
    IS
   
        --変数宣言 
        RECORDCOUNT   NUMBER; 
        dtLatestDate   T_INVENTORY_HISTORY_TO.T_TIME%TYPE; 
        DateCount   NUMBER; 
    
    BEGIN
    
        --debug
        DELETE FROM T_DEBUG;

        --T_***_BACKUPテーブルよりデータを戻す
        DELETE from T_INITIAL_TO;
        INSERT INTO T_INITIAL_TO SELECT * FROM T_INITIAL_TO_BACKUP;

        DELETE from T_INVENTORY_HISTORY_TO;
        INSERT INTO T_INVENTORY_HISTORY_TO SELECT * FROM T_INVENTORY_HISTORY_TO_BACKUP;

        DELETE from T_PIC_MASTER_TO;
        INSERT INTO T_PIC_MASTER_TO SELECT * FROM T_PIC_MASTER_TO_BACKUP;

        DELETE from T_INVENTORY_TO;
        INSERT INTO T_INVENTORY_TO SELECT * FROM T_INVENTORY_TO_BACKUP;

        --HTへのマスタ用ワークテーブルを削除
        DELETE FROM T_INVENTORY_WORK_TO;
        DELETE FROM T_INVENTORY_WORK2_TO;

        --↓ T_INVENTORY_HISTORY_TOの日付を新しくする -------------------------------------------------------------------- 

        -- T_INVENTORY_HISTORY_TOのレコードがあるかどうか
        BEGIN
            select
                COUNT(*) 
                INTO RECORDCOUNT
            FROM
                T_INVENTORY_HISTORY_TO;
        END;
        
        --もしデータがなければ抜ける
        IF RECORDCOUNT = 0 then
            return;
        END IF;
        
        --debug
        --INSERT INTO T_DEBUG (T_MESSAGE) VALUES(TO_CHAR(RECORDCOUNT));

        --最も新しい日付を取得
        BEGIN
            SELECT
                MAX(T_TIME)
                INTO dtLatestDate
            FROM
                T_INVENTORY_HISTORY_TO;
        END;
        --debug
        --INSERT INTO T_DEBUG (T_MESSAGE) VALUES(TO_CHAR(dtLatestDate));

        --本日との差分を取得
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
        
        --日付を更新
        UPDATE
            T_INVENTORY_HISTORY_TO
        SET
            T_TIME = FROM_TZ (cast(T_TIME + DateCount as timestamp), 'ASIA/TOKYO');
        
        --最も新しい日付を取得
        BEGIN
            SELECT
                MAX(T_TIME)
                INTO dtLatestDate
            FROM
                T_INVENTORY_HISTORY_TO;
        END;
        --debug
        --INSERT INTO T_DEBUG (T_MESSAGE) VALUES(TO_CHAR(dtLatestDate));

        --↑ T_INVENTORY_HISTORY_TOの日付を新しくする -------------------------------------------------------------------- 

    END fnc_ResetDemoData; 
 
 
    --デモデータリセットJOB作成 
    procedure fnc_JobCreate IS 
    BEGIN 
        DBMS_SCHEDULER.CREATE_JOB( 
        job_name => 'JOB_TO_RESET_DEMO_DATA',  
        job_type => 'STORED_PROCEDURE',  
        job_action => 'PKG_TO_RESET_DEMO_DATA.fnc_ResetDemoData',  
        start_date => TO_TIMESTAMP_TZ(CONCAT(TO_CHAR(CURRENT_DATE, 'yyyy/MM/dd'), ' 00:00:00 +09:00'),'yyyy/mm/dd hh24:mi:ss TZH:TZM'),
        repeat_interval => 'FREQ=DAILY;BYHOUR=0;',  
        auto_drop => FALSE, enabled => TRUE); 
    END fnc_JobCreate; 
   
 
    --デモデータリセットJOB削除 
    procedure fnc_JobDelete IS 
    BEGIN 
        DBMS_SCHEDULER.DROP_JOB('JOB_TO_RESET_DEMO_DATA'); 
    END fnc_JobDelete; 
 
 
    --デモデータリセットJOB有効化 
    procedure fnc_JobEnabled IS 
    BEGIN 
        DBMS_SCHEDULER.ENABLE('JOB_TO_RESET_DEMO_DATA'); 
    END fnc_JobEnabled; 
 
 
    --デモデータリセットJOB無効化 
    procedure fnc_JobDisabled IS 
    BEGIN 
        DBMS_SCHEDULER.DISABLE('JOB_TO_RESET_DEMO_DATA'); 
    END fnc_JobDisabled; 
 
END PKG_TO_RESET_DEMO_DATA; 
/
--TRIGGER
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
--その他---------------------------------------------------------------------------------------------------
--過去データ削除JOBの作成＆有効化を実行
begin
 PKG_TO_DELETE_OLD_DATA.fnc_JobCreate;
 PKG_TO_DELETE_OLD_DATA.fnc_JobEnabled;
end;
/
--担当者マスタに初期データを挿入T_PIC：admin T_PIC_NAME:admin T_PASSWORD:39393939(16進＆小文字[9999])
INSERT INTO T_PIC_MASTER_TO ( T_PIC,T_PIC_NAME,T_PASSWORD) VALUES ('admin','admin','39393939');

INSERT INTO T_PIC_MASTER_TO_BACKUP ( T_PIC,T_PIC_NAME,T_PASSWORD) VALUES ('admin','admin','39393939');

--環境設定テーブルに棚卸開始フラグの値を追加
INSERT INTO T_INITIAL_TO ( T_INITIAL_ID,T_INITIAL_VALUE,T_CONTENTS) VALUES ('26','0','棚卸開始フラグ');

INSERT INTO T_INITIAL_TO_BACKUP ( T_INITIAL_ID,T_INITIAL_VALUE,T_CONTENTS) VALUES ('26','0','棚卸開始フラグ');
