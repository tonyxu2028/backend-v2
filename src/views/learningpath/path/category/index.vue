<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="学习路径分类"></back-bar>
    <div class="float-left mb-30">
      <p-button
        text="添加分类"
        p="addons.learnPaths.category.store"
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
          :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
          class="float-left"
        >
          <el-table-column prop="id" label="ID" width="150"> </el-table-column>
          <el-table-column prop="sort" label="升序" width="150">
          </el-table-column>

          <el-table-column label="分类名"
            ><template slot-scope="scope">
              <span>{{ scope.row.name }} </span>
            </template>
          </el-table-column>
          <el-table-column fixed="right" label="操作" width="160">
            <template slot-scope="scope">
              <p-link
                text="编辑"
                p="addons.learnPaths.category.update"
                type="primary"
                @click="updateCategory(scope.row.id)"
              ></p-link>
              <p-link
                text="删除"
                p="addons.learnPaths.category.delete"
                class="ml-5"
                type="danger"
                @click="destory(scope.row.id)"
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
    <categories-dialog
      :key="updateId"
      v-if="showAddWin"
      :categories="categories"
      :text="tit"
      :id="updateId"
      @close="showAddWin = false"
      @success="successEvt"
    ></categories-dialog>
  </div>
</template>
<script>
import CategoriesDialog from "./components/categories-dialog";
export default {
  components: {
    CategoriesDialog,
  },
  data() {
    return {
      pageName: "learnPathCategory-list",
      pagination: {
        page: 1,
        size: 10,
      },
      total: 0,
      loading: false,
      categories: [],
      showAddWin: false,
      tit: null,
      updateId: null,
    };
  },
  activated() {
    this.getCategories();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    addCategory() {
      this.tit = "添加分类";
      this.updateId = null;
      this.showAddWin = true;
    },
    updateCategory(id) {
      this.tit = "编辑分类";
      this.updateId = id;
      this.showAddWin = true;
    },
    successEvt() {
      this.showAddWin = false;
      this.paginationReset();
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
    sortChange(column) {
      this.pagination.sort = column.prop;
      this.pagination.order = column.order === "ascending" ? "asc" : "desc";
      this.getCategories();
    },
    getCategories() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.pagination);
      this.$api.Course.LearnPath.Path.Category.List(params).then((res) => {
        this.loading = false;
        this.categories = res.data.data;
        this.total = res.data.total;
      });
    },
    importUser() {},
    //删除管理员
    destory(id) {
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
          this.$api.Course.LearnPath.Path.Category.Destory(id)
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
  },
};
</script>
