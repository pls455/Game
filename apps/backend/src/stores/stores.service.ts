import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { DatabaseService } from '../database/database.service';

type StoreInput = { name: string; phone?: string; address?: string; currency?: string };

@Injectable()
export class StoresService {
  constructor(private readonly db: DatabaseService) {}

  async create(userId: string, input: StoreInput) {
    const existing = await this.db.query(`SELECT 1 FROM store_users WHERE user_id=$1 LIMIT 1`, [userId]);
    if (existing.rowCount) throw new ConflictException('هذا الحساب مرتبط بدكان بالفعل');

    return this.db.transaction(async (client) => {
      const storeId = randomUUID();
      const store = await client.query(
        `INSERT INTO stores (id,owner_id,name,phone,address,currency) VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
        [storeId, userId, input.name.trim(), input.phone?.trim() || null, input.address?.trim() || null, input.currency?.trim() || 'ILS'],
      );
      await client.query(
        `INSERT INTO store_users (id,store_id,user_id,role) VALUES ($1,$2,$3,'owner')`,
        [randomUUID(), storeId, userId],
      );
      return store.rows[0];
    });
  }

  async getForUser(userId: string) {
    const result = await this.db.query(
      `SELECT s.*, su.role FROM stores s JOIN store_users su ON su.store_id=s.id WHERE su.user_id=$1 AND s.deleted_at IS NULL ORDER BY s.created_at LIMIT 1`,
      [userId],
    );
    if (!result.rowCount) throw new NotFoundException('ما في دكان مرتبط بالحساب');
    return result.rows[0];
  }

  async updateForUser(userId: string, input: StoreInput) {
    const current = await this.getForUser(userId);
    const result = await this.db.query(
      `UPDATE stores SET name=$2,phone=$3,address=$4,currency=$5,updated_at=now() WHERE id=$1 RETURNING *`,
      [current.id, input.name.trim(), input.phone?.trim() || null, input.address?.trim() || null, input.currency?.trim() || current.currency],
    );
    return result.rows[0];
  }
}
