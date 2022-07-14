<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="奖励记录"></back-bar>
    <div class="float-left j-b-flex mb-30">
      <div class="d-flex">
        <div>
          <el-input
            class="w-150px"
            v-model="filter.order_id"
            placeholder="订单ID"
          ></el-input>
        </div>

        <div class="ml-10">
          <el-button @click="paginationReset">清空</el-button>
          <el-button @click="firstPageLoad" type="primary">筛选</el-button>
        </div>
      </div>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="list"
          class="float-left"
        >
          <el-table-column prop="id" label="ID"> </el-table-column>
          <el-table-column prop="order_id" label="订单ID" width="100">
          </el-table-column>
          <el-table-column label="订单商品" width="260">
            <template slot-scope="scope">
              <div class="d-flex" v-if="scope.row.order.goods">
                <div
                  v-for="item in scope.row.order.goods"
                  :key="item.id"
                  class="ml-10"
                >
                  {{ item.goods_text }}：{{ item.goods_name }}
                </div>
              </div>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="订单用户" width="280">
            <template slot-scope="scope">
              <div class="user-item d-flex" v-if="scope.row.order_user">
                <div class="avatar">
                  <img
                    :src="scope.row.order_user.avatar"
                    width="40"
                    height="40"
                  />
                </div>
                <div class="ml-10">{{ scope.row.order_user.nick_name }}</div>
              </div>
              <span class="c-red" v-else>用户不存在</span>
            </template>
          </el-table-column>
          <el-table-column label="一级用户及奖励" width="300">
            <template slot-scope="scope">
              <div class="user-item d-flex" v-if="scope.row.user1">
                <div class="avatar">
                  <img :src="scope.row.user1.avatar" width="40" height="40" />
                </div>
                <div class="ml-10">
                  {{ scope.row.user1.nick_name }}：{{ scope.row.reward1 }}元
                </div>
              </div>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="二级用户及奖励" width="300">
            <template slot-scope="scope">
              <div class="user-item d-flex" v-if="scope.row.user2">
                <div class="avatar">
                  <img :src="scope.row.user2.avatar" width="40" height="40" />
                </div>
                <div class="ml-10">
                  {{ scope.row.user2.nick_name }}：{{ scope.row.reward2 }}元
                </div>
              </div>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="三级用户及奖励" width="300">
            <template slot-scope="scope">
              <div class="user-item d-flex" v-if="scope.row.user3">
                <div class="avatar">
                  <img :src="scope.row.user3.avatar" width="40" height="40" />
                </div>
                <div class="ml-10">
                  {{ scope.row.user3.nick_name }}：{{ scope.row.reward3 }}元
                </div>
              </div>
              <span v-else>-</span>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <div class="float-left mt-30 text-center">
        <el-pagination
          @size-change="paginationSizeChange"
          @current-change="paginationPageChange"
          :current-page="pagination.page"
          :page-sizes="[10, 20, 50, 100]"
          :page-size="pagination.size"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
        >
        </el-pagination>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      pagination: {
        page: 1,
        size: 10,
      },
      filter: {
        order_id: null,
      },
      total: 0,
      loading: false,
      list: [],
    };
  },

  mounted() {
    this.getData();
  },
  methods: {
    paginationReset() {
      this.pagination.page = 1;
      this.filter.order_id = null;
      this.getData();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getData();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getData();
    },
    firstPageLoad() {
      this.pagination.page = 1;
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.filter);
      Object.assign(params, this.pagination);
      this.$api.Multishare.Goods.Rewards(params).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;
      });
    },
  },
};
</script>
