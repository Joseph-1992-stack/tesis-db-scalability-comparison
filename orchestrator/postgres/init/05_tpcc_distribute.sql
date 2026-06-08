BEGIN;

CREATE EXTENSION IF NOT EXISTS citus;

-- 1) Distribuir tabla ancla
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_dist_partition
    WHERE logicalrelid = 'tpcc.warehouse'::regclass
  ) THEN
    PERFORM create_distributed_table('tpcc.warehouse', 'w_id');
    RAISE NOTICE '✅ Distributed tpcc.warehouse';
  ELSE
    RAISE NOTICE 'ℹ️  tpcc.warehouse already distributed';
  END IF;
END $$;

-- 2) Distribuir/co-localizar hijas (una por una, sin loop para evitar errores)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_dist_partition WHERE logicalrelid='tpcc.district'::regclass) THEN
    PERFORM create_distributed_table('tpcc.district','d_w_id', colocate_with => 'tpcc.warehouse');
    RAISE NOTICE '✅ Distributed tpcc.district';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_dist_partition WHERE logicalrelid='tpcc.customer'::regclass) THEN
    PERFORM create_distributed_table('tpcc.customer','c_w_id', colocate_with => 'tpcc.warehouse');
    RAISE NOTICE '✅ Distributed tpcc.customer';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_dist_partition WHERE logicalrelid='tpcc.orders'::regclass) THEN
    PERFORM create_distributed_table('tpcc.orders','o_w_id', colocate_with => 'tpcc.warehouse');
    RAISE NOTICE '✅ Distributed tpcc.orders';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_dist_partition WHERE logicalrelid='tpcc.order_line'::regclass) THEN
    PERFORM create_distributed_table('tpcc.order_line','ol_w_id', colocate_with => 'tpcc.warehouse');
    RAISE NOTICE '✅ Distributed tpcc.order_line';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_dist_partition WHERE logicalrelid='tpcc.new_order'::regclass) THEN
    PERFORM create_distributed_table('tpcc.new_order','no_w_id', colocate_with => 'tpcc.warehouse');
    RAISE NOTICE '✅ Distributed tpcc.new_order';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_dist_partition WHERE logicalrelid='tpcc.stock'::regclass) THEN
    PERFORM create_distributed_table('tpcc.stock','s_w_id', colocate_with => 'tpcc.warehouse');
    RAISE NOTICE '✅ Distributed tpcc.stock';
  END IF;
END $$;

COMMIT;