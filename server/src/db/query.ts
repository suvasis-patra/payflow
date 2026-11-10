import { QueryResult, QueryResultRow } from "pg";
import { pool } from "./connection";

export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  values: any[] = [],
): Promise<QueryResult<T>> {
  return pool.query<T>(text, values);
}
