import snowflake from 'snowflake-sdk';
import fs from 'fs';
import crypto from 'crypto';

export function getConnection(): Promise<snowflake.Connection> {
  return new Promise((resolve, reject) => {
    const privateKeyPath = process.env.SNOWFLAKE_PRIVATE_KEY_PATH || '';
    const privateKeyPass = process.env.SNOWFLAKE_PRIVATE_KEY_PASSPHRASE || '';

    const connOpts: any = {
      account: process.env.SNOWFLAKE_ACCOUNT || '',
      username: process.env.SNOWFLAKE_USER || '',
      database: process.env.SNOWFLAKE_DATABASE || 'GHOST_DETECTION',
      schema: process.env.SNOWFLAKE_SCHEMA || 'APP',
      warehouse: process.env.SNOWFLAKE_WAREHOUSE || '',
      role: process.env.SNOWFLAKE_ROLE || 'ACCOUNTADMIN',
      authenticator: 'SNOWFLAKE_JWT',
    };

    if (privateKeyPath) {
      const keyFile = fs.readFileSync(privateKeyPath, 'utf8');
      const privateKeyObj = crypto.createPrivateKey({
        key: keyFile,
        format: 'pem',
        passphrase: privateKeyPass || undefined,
      });
      connOpts.privateKey = privateKeyObj.export({ type: 'pkcs8', format: 'pem' }).toString();
    }

    const conn = snowflake.createConnection(connOpts);
    conn.connect((err) => {
      if (err) reject(err);
      else resolve(conn);
    });
  });
}

export function executeQuery(conn: snowflake.Connection, sql: string, binds?: any[]): Promise<any[]> {
  return new Promise((resolve, reject) => {
    conn.execute({
      sqlText: sql,
      binds: binds || [],
      complete: (err, _stmt, rows) => {
        if (err) reject(err);
        else resolve(rows || []);
      },
    });
  });
}
