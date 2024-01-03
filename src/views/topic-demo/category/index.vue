<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="图文分类管理"></back-bar>
    <div class="float-left mb-30">
      <p-button
          text="新建分类"
          p="courseCategory.store"
          @click="addCategory"
          type="primary"
      >
      </p-button>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
            :header-cell-style="{ background: '#f1f2f9' }"
            :data="categories"
            row-key="id"
            class="float-left"
        >
          <el-table-column prop="sort" label="排序" width="150">
          </el-table-column>

          <el-table-column label="分类名"
          ><template slot-scope="scope">
            <span>{{ scope.row.name }} </span>
          </template>
          </el-table-column>
          <el-table-column fixed="right" label="操作" width="100">
            <template slot-scope="scope">
              <p-link
                  text="编辑"
                  p="courseCategory.update"
                  type="primary"
                  @click="updateCategory(scope.row.id)"
              ></p-link>
              <p-link
                  text="删除"
                  p="courseCategory.destroy"
                  class="ml-5"
                  type="danger"
                  @click="destroy(scope.row.id)"
              ></p-link>
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
  data(){
    return {
      categories: [],
      pagination: {
        page: 1,
        size: 10,
      },
      total: 0,
      loading: false,
    };
  },
  methods: {
    addCategory() {
      this.tit = "新建分类";
      this.updateId = null;
      this.showAddWin = true;
    },
    updateCategory(id) {
      this.tit = "编辑分类";
      this.updateId = id;
      this.showAddWin = true;
    },
    paginationReset() {
      this.pagination.page = 1;
      this.getCategories();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getCategories();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getCategories();
    },
    getCategories() {                         // 列表的数据获取方法
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.pagination);
      this.$api.TopicDemo.Category.List(params).then((res) => {
        this.loading = false;
        this.categories = res.data.data;
        this.total = res.data.total;
      });
    },
    destroy(id) {
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
            this.$api.TopicDemo.Category.Destroy(id)
                .then(() => {
                  this.loading = false;
                  this.$message.success(this.$t("common.success"));
                  this.paginationReset();
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
  }
}
</script>

<style scoped lang="less">

</style>

