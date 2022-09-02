<template>
  <div class="float-left">
    <el-table
      :header-cell-style="{ background: '#f1f2f9' }"
      v-loading="loading"
      :data="list"
      class="float-left"
    >
      <el-table-column prop="admin_id" label="管理员ID" width="100">
      </el-table-column>
      <el-table-column prop="module" label="操作模块" width="100">
      </el-table-column>
      <el-table-column prop="opt" label="操作指令" width="100">
      </el-table-column>
      <el-table-column prop="ip" label="IP" width="200"> </el-table-column>
      <el-table-column label="时间" width="200">
        <template slot-scope="scope">{{
          scope.row.created_at | dateWholeFormat
        }}</template>
      </el-table-column>
      <el-table-column label="备注">
        <template slot-scope="scope">
          <code>{{ scope.row.remark }}</code>
        </template>
      </el-table-column>
    </el-table>

    <div class="float-left mt-15 text-center">
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
</template>
<script>
export default {
  props: ["id"],
  data() {
    return {
      pagination: {
        page: 1,
        size: 10,
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
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getData();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.System.Log.Admin(this.pagination).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;
      });
    },
  },
};
</script>
