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
          <el-table-column prop="id" label="ID" width="150"> </el-table-column>
          <el-table-column label="支付订单" width="200">
            <template slot-scope="scope">
              <span>{{ scope.row.order.order_id }}</span
              ><br />
              <span style="color: rgba(0, 0, 0, 0.2)">ID: {{
                scope.row.order.id
              }}</span>
            </template>
          </el-table-column>
          <el-table-column label="订单商品">
            <template slot-scope="scope">
              <div class="d-flex" v-if="scope.row.order.goods">
                <div
                  v-for="item in scope.row.order.goods"
                  :key="item.id"
                  class="mr-10"
                >
                  {{ item.goods_name }}
                </div>
              </div>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="支付学员" width="300">
            <template slot-scope="scope">
              <div class="user-item d-flex" v-if="scope.row.order_user">
                <div>
                  {{ scope.row.order_user.nick_name }}<br />
                  <span style="color: rgba(0, 0, 0, 0.2)"
                    >ID: {{ scope.row.order_user.id }}</span
                  >
                </div>
              </div>
              <span class="c-red" v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="一级学员奖励" width="260">
            <template slot-scope="scope">
              <div
                style="color: rgba(255, 0, 0, 1)"
                class="flex flex-column"
                v-if="scope.row.user1"
              >
                <div>{{ scope.row.user1.nick_name }}</div>
                <div>{{ scope.row.reward1 }}元</div>
              </div>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="二级学员奖励" width="260">
            <template slot-scope="scope">
              <div
                style="color: rgba(255, 0, 0, 0.6)"
                class="flex flex-column"
                v-if="scope.row.user2"
              >
                <div>{{ scope.row.user2.nick_name }}</div>
                <div>{{ scope.row.reward2 }}元</div>
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
        size: 50,
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
