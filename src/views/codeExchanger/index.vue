<template>
  <div class="meedu-main-body">
    <div class="float-left j-b-flex mb-30">
      <div class="d-flex">
        <p-button
          text="新建兑换活动"
          @click="$router.push({ name: 'CodeExchangerCreate' })"
          type="primary"
          p="addons.CodeExchanger.activity.store"
        >
        </p-button>
      </div>
      <div class="d-flex">
        <div>
          <el-input
            class="w-150px"
            v-model="filter.name"
            placeholder="活动名"
          ></el-input>
        </div>
        <div class="ml-10">
          <el-button @click="paginationReset">清空</el-button>
          <el-button @click="firstPageLoad()" type="primary">筛选</el-button>
        </div>
      </div>
    </div>
    <div class="float-left" v-loading="loading">
      <el-table
        :header-cell-style="{ background: '#f1f2f9' }"
        :data="list"
        class="float-left"
      >
        <el-table-column prop="id" label="ID" width="100"> </el-table-column>
        <el-table-column prop="name" label="活动名" width="120">
        </el-table-column>
        <el-table-column label="商品数量" width="100">
          <template slot-scope="scope">
            <span>{{ JSON.parse(scope.row.relate_data).length }}个商品</span>
          </template>
        </el-table-column>
        <el-table-column label="兑换商品">
          <template slot-scope="scope">
            <div
              v-for="item in JSON.parse(scope.row.relate_data)"
              :key="item.id"
            >
              <span v-if="item.sign === 'vod'">录播-{{ item.name }}</span>
              <span v-else-if="item.sign === 'live'">直播-{{ item.name }}</span>
              <span v-else-if="item.sign === 'book'"
                >电子书-{{ item.name }}</span
              >
              <span v-else-if="item.sign === 'paper'"
                >考试-{{ item.name }}</span
              >
              <span v-else-if="item.sign === 'mock_paper'"
                >模拟-{{ item.name }}</span
              >
              <span v-else-if="item.sign === 'practice'"
                >练习-{{ item.name }}</span
              >
              <span v-else-if="item.sign === 'vip'">VIP-{{ item.name }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="商品总价" width="200">
          <template slot-scope="scope">
            <span>{{ totalPrice(JSON.parse(scope.row.relate_data)) }}元</span>
          </template>
        </el-table-column>
        <el-table-column label="兑换码" width="300">
          <template slot-scope="scope">
            <span>{{ scope.row.used_count }}/{{ scope.row.code_count }}</span>
          </template>
        </el-table-column>
        <el-table-column fixed="right" label="操作" width="150">
          <template slot-scope="scope">
            <p-link
              type="primary"
              text="兑换码"
              @click="
                $router.push({
                  name: 'CodeExchangerCodes',
                  query: { id: scope.row.id },
                })
              "
              p="addons.CodeExchanger.activity-code.list"
            ></p-link>
            <p-link
              class="ml-5"
              type="primary"
              text="编辑"
              @click="
                $router.push({
                  name: 'CodeExchangerUpdate',
                  query: { id: scope.row.id },
                })
              "
              p="addons.CodeExchanger.activity.update"
            ></p-link>
            <p-link
              class="ml-5"
              text="删除"
              type="danger"
              @click="destory(scope.row.id)"
              p="addons.CodeExchanger.activity.destroy"
            ></p-link>
          </template>
        </el-table-column>
      </el-table>
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
      pageName: "codeExchanger-list",
      pagination: {
        page: 1,
        size: 10,
      },
      filter: {
        name: null,
      },
      total: 0,
      loading: false,
      list: [],
    };
  },
  activated() {
    this.getData();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    firstPageLoad() {
      this.pagination.page = 1;
      this.getData();
    },
    paginationReset() {
      this.pagination.page = 1;
      this.filter.name = null;
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
    totalPrice(data) {
      let price = 0;
      for (var i = 0; i < data.length; i++) {
        price = parseFloat(data[i].charge) + price;
      }
      return price;
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.filter, this.pagination);
      this.$api.CodeExchanger.List(params).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;
      });
    },
    destory(item) {
      this.$confirm("确认操作？", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          //点击确定按钮的操作
          if (this.loading) {
            return;
          }
          this.loading = true;
          this.$api.CodeExchanger.Destory(item)
            .then(() => {
              this.loading = false;
              this.$message.success(this.$t("common.success"));
              this.getData();
            })
            .catch((e) => {
              this.loading = false;
              this.$message.error(e.message);
            });
        })
        .catch(() => {
          //点击删除按钮的操作
        });
    },
  },
};
</script>
