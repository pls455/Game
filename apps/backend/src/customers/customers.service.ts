import { Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { DatabaseService } from '../database/database.service';

type CustomerInput = { name: string; phone?: string; address?: string; notes?: string; openingBalance?: number };

@Injectable()
export class CustomersService {
  constructor(private readonly db: DatabaseService) {}

  private async storeIdForUser(userId: string) {
    const result = await this.db.query(`SELECT store_id FROM store_users WHERE user_id=$1 ORDER BY created_at LIMIT 1`, [userId]);
    if (!result.rowCount) throw new NotFoundException('أنشئ دكانتك أولاً');
    return result.rows[0].store_id as string;
  }

  async list(userId: string, search = '', limit = 30) {
    const storeId = await this.storeIdForUser(userId);
    const safeLimit = Math.min(Math.max(limit, 1), 50);
    const result = await this.db.query(
      `SELECT c.*, COALESCE(c.opening_balance + COALESCE((SELECT SUM(CASE WHEN ct.type IN ('sale','adjustment','opening_balance') THEN ct.amount ELSE -ct.amount END) FROM customer_transactions ct WHERE ct.customer_id=c.id),0), c.opening_balance) AS balance
       FROM customers c WHERE c.store_id=$1 AND c.deleted_at IS NULL AND ($2='' OR c.name ILIKE '%'||$2||'%' OR COALESCE(c.phone,'') ILIKE '%'||$2||'%') ORDER BY c.name LIMIT $3`,
      [storeId, search.trim(), safeLimit],
    );
    return result.rows;
  }

  async create(userId: string, input: CustomerInput) {
    const storeId = await this.storeIdForUser(userId);
    const id = randomUUID();
    return this.db.transaction(async (client) => {
      const result = await client.query(
        `INSERT INTO customers (id,store_id,name,phone,address,notes,opening_balance) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
        [id, storeId, input.name.trim(), input.phone?.trim() || null, input.address?.trim() || null, input.notes?.trim() || null, input.openingBalance ?? 0],
      );
      if ((input.openingBalance ?? 0) !== 0) {
        await client.query(
          `INSERT INTO customer_transactions (id,store_id,customer_id,type,amount,note,created_by) VALUES ($1,$2,$3,'opening_balance',$4,$5,$6)`,
          [randomUUID(), storeId, id, Math.abs(input.openingBalance ?? 0), 'رصيد افتتاحي', userId],
        );
      }
      return result.rows[0];
    });
  }

  async get(userId: string, customerId: string) {
    const storeId = await this.storeIdForUser(userId);
    const result = await this.db.query(
      `SELECT c.*, COALESCE(c.opening_balance + COALESCE((SELECT SUM(CASE WHEN ct.type IN ('sale','adjustment','opening_balance') THEN ct.amount ELSE -ct.amount END) FROM customer_transactions ct WHERE ct.customer_id=c.id),0), c.opening_balance) AS balance FROM customers c WHERE c.id=$1 AND c.store_id=$2 AND c.deleted_at IS NULL`,
      [customerId, storeId],
    );
    if (!result.rowCount) throw new NotFoundException('مش لاقيين هالزبون');
    return result.rows[0];
  }

  async update(userId: string, customerId: string, input: CustomerInput) {
    const storeId = await this.storeIdForUser(userId);
    const result = await this.db.query(
      `UPDATE customers SET name=$3,phone=$4,address=$5,notes=$6,version=version+1,updated_at=now() WHERE id=$1 AND store_id=$2 AND deleted_at IS NULL RETURNING *`,
      [customerId, storeId, input.name.trim(), input.phone?.trim() || null, input.address?.trim() || null, input.notes?.trim() || null],
    );
    if (!result.rowCount) throw new NotFoundException('مش لاقيين هالزبون');
    return result.rows[0];
  }

  async statement(userId: string, customerId: string) {
    await this.get(userId, customerId);
    const result = await this.db.query(
      `SELECT id,type,amount,reference_type,reference_id,note,created_at,created_by FROM customer_transactions WHERE customer_id=$1 ORDER BY created_at ASC`,
      [customerId],
    );
    return result.rows;
  }
}
