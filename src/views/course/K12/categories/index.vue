<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="大小班分类"></back-bar>

    <div class="float-left mb-30">
      <p-button
        text="添加分类"
        @click="addCategory"
        type="primary"
        p="addons.XiaoBanKe.course_category.store"
      >
      </p-button>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="list"
          row-key="name"
          :tree-props="{ children: 'children' }"
          class="float-left"
        >
          <el-table-column prop="name" label="分类名"> </el-table-column>
          <el-table-column prop="sort" label="升序" width="300">
          </el-table-column>
          <el-table-column fixed="right" label="操作" width="120">
            <template slot-scope="scope">
              <p-link
                text="编辑"
                type="primary"
                @click="updateCategory(scope.row.id)"
                p="addons.XiaoBanKe.course_category.update"
              ></p-link>
              <p-link
                class="ml-5"
                text="删除"
                type="danger"
                @click="destory(scope.row.id)"
                p="addons.XiaoBanKe.course_category.delete"
              ></p-link>
            </template>
          </el-table-column>
        </el-table>
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
      pageName: "k12Category-list",
      loading: false,
      list: [],
      categories: [],
      showAddWin: false,
      tit: null,
      updateId: null,
    };
  },
  mounted() {
    this.create();
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
    create() {
      this.$api.xiaoBanKe.CourseCategory.Create().then((res) => {
        var data = res.data;
        this.categories = data.categories;
      });
    },
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
      this.create();
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.xiaoBanKe.CourseCategory.List().then((res) => {
        this.loading = false;
        this.list = res.data.data.data;
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
          this.$api.xiaoBanKe.CourseCategory.Destroy(item)
            .then(() => {
              this.loading = false;
              this.$message.success(this.$t("common.success"));
              this.create();
              this.getData();
            })
            .catch((e) => {
              this.loading = false;
              this.$message.warning(e.message);
            });
        })
        .catch(() => {
          //点击删除按钮的操作
        });
    },
  },
};
</script>
