<template>
  <div class="float-left">
    <el-table
      :header-cell-style="{ background: '#f1f2f9' }"
      v-loading="loading"
      :data="list"
      class="float-left"
    >
      <el-table-column prop="order_id" label="订单编号" width="200">
      </el-table-column>
      <el-table-column label="订单商品">
        <template slot-scope="scope">
          <div class="d-flex" v-for="item in scope.row.goods" :key="item.id">
            <div>
              <template v-if="item.goods_type === 'ROLE'">
                <thumb-bar
                  :value="require('@/assets/img/default-vip.png')"
                  :width="120"
                  :height="90"
                  :border="4"
                ></thumb-bar>
              </template>
              <template
                v-else-if="
                  item.goods_type === '模拟试卷' ||
                  item.goods_type === '试卷' ||
                  item.goods_type === '练习'
                "
              >
                <thumb-bar
                  :value="require('@/assets/img/default-paper.png')"
                  :width="120"
                  :height="90"
                  :border="4"
                ></thumb-bar>
              </template>
              <template v-else-if="item.goods_type === 'BOOK'">
                <div class="item-thumb">
                  <thumb-bar
                    :value="item.goods_thumb"
                    :width="67.5"
                    :height="90"
                    :border="4"
                  ></thumb-bar>
                </div>
              </template>
              <template v-else>
                <thumb-bar
                  :value="item.goods_thumb"
                  :width="120"
                  :height="90"
                  :border="4"
                ></thumb-bar>
              </template>
            </div>
            <div class="flex-1 ml-15">
              {{ item.goods_name }}
            </div>
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="charge" label="支付金额" width="200">
      </el-table-column>
      <el-table-column label="付款时间" width="200">
        <template slot-scope="scope">{{
          scope.row.created_at | dateFormat
        }}</template>
      </el-table-column>
    </el-table>

    <div class="float-left mt-15">
      <el-pagination
        background
        :page-size="pagination.size"
        :current-page="pagination.page"
        layout="prev, pager, next, total"
        @current-change="pageChange"
        :total="total"
      >
      </el-pagination>
    </div>
  </div>
</template>
<script>
export default {
  props: ["id"],
  data() {
    return {
      pagination: {
        page: 1,
        size: 8,
        status: 9,
      },
      total: 0,
      list: [],
      loading: false,
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    pageChange(page) {
      this.pagination.page = page;
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Member.UserOrders(this.id, this.pagination).then((res) => {
        this.loading = false;
        this.list = res.data.data.data;
        this.total = res.data.data.total;
      });
    },
  },
};
</script>
