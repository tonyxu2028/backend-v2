<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="图文分类管理"></back-bar>
    <div class="float-left mb-30">
      <p-button
          text="新建分类"
          p="demo–topic.category.store"
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
          <el-table-column prop="id" label="序号" width="150">
          </el-table-column>

          <el-table-column prop="sort" label="升序" width="150">
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
                  p="demo–topic.category.update"
                  type="primary"
                  @click="updateCategory(scope.row.id)"
              ></p-link>
              <p-link
                  text="删除"
                  p="demo–topic.category.destroy"
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
    <form-comp :title="formTitle" :id="editId" v-if="showForm" @close="closeForm()" @success="sucEvt()">
    </form-comp>
  </div>
</template>

<script>
import FormComp from "./components/form.vue";
export default {
  components: {
    FormComp,
  },
  data(){
    return {
      categories: [],
      pagination: {
        page: 1,
        size: 10,
      },
      total: 0,
      loading: false,
      showForm:false,
      formTitle:"",
      editId:null,
    };
  },
  mounted() {
    this.getCategories();
  },
  methods: {
    addCategory() {
      this.formTitle = "新建分类";
      this.editId = null;
      this.showForm = true;
    },
    updateCategory(id) {
      this.formTitle = "编辑分类";
      this.editId = id;
      this.showForm = true;
    },
    closeForm() {
      this.formTitle = "";
      this.editId = null;
      this.showForm = false;
    },
    sucEvt() {
      this.closeForm();
      this.getCategories();
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
    getCategories() {// 列表的数据获取方法
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

