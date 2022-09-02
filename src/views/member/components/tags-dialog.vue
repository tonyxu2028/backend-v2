<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-cate-dialog-box">
        <div class="meedu-dialog-header">修改标签</div>
        <div class="meedu-dialog-body">
          <div class="float-left" v-if="tags">
            <el-form
              ref="form"
              class="float-left"
              :model="form"
              :rules="rules"
              label-width="110px"
            >
              <el-form-item label="学员标签">
                <div class="d-flex">
                  <div>
                    <el-select
                      class="w-500px"
                      multiple
                      clearable
                      v-model="form.tagIds"
                    >
                      <el-option
                        v-for="(item, index) in tags"
                        :key="index"
                        :label="item.name"
                        :value="item.id"
                      >
                      </el-option>
                    </el-select>
                  </div>
                  <div class="ml-15">
                    <el-link
                      @click="$router.push({ name: 'MemberTagIndex' })"
                      type="primary"
                    >
                      标签管理
                    </el-link>
                  </div>
                </div>
              </el-form-item>
            </el-form>
          </div>
        </div>
        <div class="meedu-dialog-footer">
          <el-button @click="formValidate" :loading="loading" type="primary">
            保存
          </el-button>
          <el-button @click="close"> 取消 </el-button>
        </div>
      </div>
    </div>
  </transition>
</template>
<script>
export default {
  props: ["id"],
  data() {
    return {
      form: {
        tagIds: [],
      },
      rules: {},
      tags: null,
      loading: false,
    };
  },
  mounted() {
    this.form.tagIds = {};
    if (this.id) {
      this.getUser();
    }
  },
  methods: {
    getUser() {
      this.$api.Member.Edit(this.id).then((res) => {
        let data = [];

        if (res.data.tags) {
          for (let i = 0; i < res.data.tags.length; i++) {
            data.push(res.data.tags[i].id);
          }
        }

        this.form.tagIds = data;
        this.params();
      });
    },
    params() {
      this.$api.Member.Create().then((res) => {
        this.tags = res.data.tags;
      });
    },
    formValidate() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.confirm();
        }
      });
    },
    close() {
      this.$emit("close");
    },
    confirm() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Member.TagUpdate(this.id, {
        tag_ids: this.form.tagIds.join(","),
      })
        .then(() => {
          this.loading = false;
          this.$message.success(this.$t("common.success"));
          this.$emit("success");
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
  },
};
</script>
